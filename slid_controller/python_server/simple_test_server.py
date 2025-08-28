import asyncio
import json
import logging
import socket
import pyautogui
from websockets.server import serve
from websockets.exceptions import ConnectionClosed

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SimpleSlideController:
    def __init__(self):
        # Disable pyautogui failsafe
        pyautogui.FAILSAFE = False
        
    def laser_pointer_move(self, x_percent, y_percent):
        """Move laser pointer to specific screen coordinates based on percentages"""
        try:
            # Get screen dimensions
            screen_width, screen_height = pyautogui.size()
            
            # Convert percentages to actual coordinates
            x = int((x_percent / 100.0) * screen_width)
            y = int((y_percent / 100.0) * screen_height)
            
            # Move mouse cursor (which acts as laser pointer in presentation mode)
            pyautogui.moveTo(x, y, duration=0.1)
            logger.info(f"🎯 Laser pointer moved to ({x}, {y}) - {x_percent:.1f}%, {y_percent:.1f}%")
            
        except Exception as e:
            logger.error(f"❌ Error moving laser pointer: {e}")
    
    def laser_pointer_toggle(self):
        """Toggle laser pointer"""
        try:
            pyautogui.hotkey('ctrl', 'l')
            logger.info("🔴 Laser pointer toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling laser pointer: {e}")
    
    def handle_command(self, command, params=None):
        """Handle incoming commands"""
        logger.info(f"📡 Received command: {command} with params: {params}")
        
        if command == 'laser_pointer':
            self.laser_pointer_toggle()
            return {'status': 'success', 'command': command}
        elif command == 'laser_pointer_move' and params:
            x_percent = params.get('x_percent', 50)
            y_percent = params.get('y_percent', 50)
            self.laser_pointer_move(x_percent, y_percent)
            return {'status': 'success', 'command': command}
        elif command == 'laser_pointer_click' and params:
            x_percent = params.get('x_percent', 50)
            y_percent = params.get('y_percent', 50)
            # Move first, then click
            self.laser_pointer_move(x_percent, y_percent)
            pyautogui.click()
            logger.info(f"👆 Clicked at {x_percent}%, {y_percent}%")
            return {'status': 'success', 'command': command}
        elif command == 'next':
            pyautogui.press('right')
            logger.info("➡️ Next slide")
            return {'status': 'success', 'command': command}
        elif command == 'previous':
            pyautogui.press('left')
            logger.info("⬅️ Previous slide")
            return {'status': 'success', 'command': command}
        else:
            return {'status': 'error', 'message': f'Unknown command: {command}'}

class SimpleServer:
    def __init__(self, host='0.0.0.0', port=8080):
        self.host = host
        self.port = port
        self.controller = SimpleSlideController()
        
    def get_local_ip(self):
        """Get the local IP address"""
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.connect(("8.8.8.8", 80))
                return s.getsockname()[0]
        except Exception:
            return "localhost"
    
    async def handle_client(self, websocket, path):
        """Handle WebSocket connections"""
        client_address = websocket.remote_address
        logger.info(f"📱 New client connected: {client_address}")
        
        try:
            async for message in websocket:
                try:
                    data = json.loads(message)
                    logger.info(f"📥 Received: {data}")
                    
                    if 'command' in data:
                        command = data['command']
                        params = data.get('params', {})
                        response = self.controller.handle_command(command, params)
                        response['timestamp'] = data.get('timestamp')
                        
                        await websocket.send(json.dumps(response))
                        logger.info(f"📤 Sent response: {response}")
                    
                except json.JSONDecodeError:
                    error_response = {'status': 'error', 'message': 'Invalid JSON format'}
                    await websocket.send(json.dumps(error_response))
                except Exception as e:
                    error_response = {'status': 'error', 'message': str(e)}
                    await websocket.send(json.dumps(error_response))
                    logger.error(f"❌ Error handling message: {e}")
                    
        except ConnectionClosed:
            logger.info(f"📱 Client {client_address} disconnected")
        except Exception as e:
            logger.error(f"❌ Error with client {client_address}: {e}")
    
    async def start(self):
        """Start the server"""
        local_ip = self.get_local_ip()
        
        logger.info("=" * 50)
        logger.info("🎯 SIMPLE SLIDE CONTROLLER SERVER")
        logger.info("=" * 50)
        logger.info(f"📱 Server running on: {local_ip}:{self.port}")
        logger.info(f"🌐 WebSocket URL: ws://{local_ip}:{self.port}")
        logger.info("=" * 50)
        logger.info("📋 INSTRUCTIONS:")
        logger.info("1. Open PowerPoint and start presentation (F5)")
        logger.info("2. Connect your phone to the IP above")
        logger.info("3. Test basic slide navigation first")
        logger.info("4. Enable laser pointer in app")
        logger.info("5. Touch the control area to move laser pointer")
        logger.info("=" * 50)
        
        try:
            async with serve(self.handle_client, self.host, self.port):
                logger.info("🚀 Server started successfully!")
                await asyncio.Future()  # Run forever
        except Exception as e:
            logger.error(f"❌ Server error: {e}")

def main():
    server = SimpleServer()
    asyncio.run(server.start())

if __name__ == "__main__":
    main()
