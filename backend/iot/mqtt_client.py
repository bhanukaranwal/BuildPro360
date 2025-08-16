import paho.mqtt.client as mqtt
import asyncio
import json
import logging
from typing import Callable, Dict, Any, Optional

class MqttClient:
    def __init__(self, broker: str, port: int, client_id: str, username: Optional[str] = None, password: Optional[str] = None):
        self.broker = broker
        self.port = port
        self.client_id = client_id
        self.username = username
        self.password = password
        self.client = mqtt.Client(client_id=client_id)
        self.loop = asyncio.get_event_loop()
        self._connected = False
        self._message_callbacks = {}
        
        # Set up callbacks
        self.client.on_connect = self._on_connect
        self.client.on_disconnect = self._on_disconnect
        self.client.on_message = self._on_message
        self.client.on_subscribe = self._on_subscribe
        
        # Set username and password if provided
        if username and password:
            self.client.username_pw_set(username, password)
        
        # Set up logging
        self.logger = logging.getLogger(__name__)
    
    def _on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            self.logger.info(f"Connected to MQTT broker {self.broker}:{self.port}")
            self._connected = True
        else:
            self.logger.error(f"Failed to connect to MQTT broker, return code {rc}")
    
    def _on_disconnect(self, client, userdata, rc):
        self.logger.info(f"Disconnected from MQTT broker with code {rc}")
        self._connected = False
    
    def _on_message(self, client, userdata, msg):
        topic = msg.topic
        payload = msg.payload.decode()
        self.logger.debug(f"Received message on topic {topic}: {payload}")
        
        # Try to parse JSON
        try:
            data = json.loads(payload)
        except json.JSONDecodeError:
            data = payload
        
        # Call the appropriate callback for this topic
        for topic_pattern, callback in self._message_callbacks.items():
            if mqtt.topic_matches_sub(topic_pattern, topic):
                asyncio.create_task(callback(topic, data))
    
    def _on_subscribe(self, client, userdata, mid, granted_qos):
        self.logger.info(f"Subscribed to topic with QoS {granted_qos}")
    
    async def connect(self):
        """Connect to the MQTT broker with retry logic"""
        max_retries = 5
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                def _connect():
                    self.client.connect(self.broker, self.port, keepalive=60)
                    self.client.loop_start()
                
                # Run connection in a thread since it's blocking
                await self.loop.run_in_executor(None, _connect)
                
                # Wait for connection to establish
                for _ in range(10):  # Wait up to 5 seconds
                    if self._connected:
                        return  # Successfully connected
                    await asyncio.sleep(0.5)
                
                # If we get here, connection didn't establish within timeout
                retry_count += 1
                self.logger.warning(f"Connection attempt {retry_count} failed, retrying...")
                
                # Cleanup before retry
                try:
                    self.client.loop_stop()
                    self.client.disconnect()
                except:
                    pass
                    
                await asyncio.sleep(2 * retry_count)  # Exponential backoff
                
            except Exception as e:
                retry_count += 1
                self.logger.error(f"MQTT connection error: {e}")
                if retry_count >= max_retries:
                    raise Exception(f"Failed to connect to MQTT broker after {max_retries} attempts: {e}")
                await asyncio.sleep(2 * retry_count)  # Exponential backoff
        
        raise Exception("Failed to connect to MQTT broker")
    
    async def disconnect(self):
        """Disconnect from the MQTT broker"""
        def _disconnect():
            self.client.loop_stop()
            self.client.disconnect()
        
        await self.loop.run_in_executor(None, _disconnect)
        self.logger.info("Disconnected from MQTT broker")
    
    async def subscribe(self, topic: str, qos: int = 0):
        """Subscribe to a topic"""
        if not self._connected:
            raise Exception("Not connected to MQTT broker")
        
        def _subscribe():
            result, _ = self.client.subscribe(topic, qos)
            if result != mqtt.MQTT_ERR_SUCCESS:
                raise Exception(f"Failed to subscribe to topic {topic}")
        
        await self.loop.run_in_executor(None, _subscribe)
        self.logger.info(f"Subscribed to topic {topic} with QoS {qos}")
    
    async def publish(self, topic: str, payload: Any, qos: int = 0, retain: bool = False):
        """Publish a message to a topic"""
        if not self._connected:
            raise Exception("Not connected to MQTT broker")
        
        # Convert payload to JSON string if it's a dict
        if isinstance(payload, dict):
            payload = json.dumps(payload)
        
        def _publish():
            result = self.client.publish(topic, payload, qos, retain)
            if result.rc != mqtt.MQTT_ERR_SUCCESS:
                raise Exception(f"Failed to publish to topic {topic}")
        
        await self.loop.run_in_executor(None, _publish)
        self.logger.debug(f"Published message to topic {topic}: {payload}")
    
    def register_callback(self, topic: str, callback: Callable[[str, Any], None]):
        """Register a callback for a topic"""
        self._message_callbacks[topic] = callback
        self.logger.debug(f"Registered callback for topic {topic}")
    
    def unregister_callback(self, topic: str):
        """Unregister a callback for a topic"""
        if topic in self._message_callbacks:
            del self._message_callbacks[topic]
            self.logger.debug(f"Unregistered callback for topic {topic}")