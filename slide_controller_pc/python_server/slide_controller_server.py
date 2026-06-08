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

class SlideController:
    def __init__(self):
        self.presentation_mode = False
        self.current_slide = 0
        self._latest_laser_move = None
        self._laser_move_worker_running = False
        
        # Disable pyautogui's fail-safe feature for presentations
        pyautogui.FAILSAFE = False
        
        # Keep commands responsive; the mobile app already throttles move events.
        pyautogui.PAUSE = 0.01
    
    def next_slide(self):
        """Move to the next slide using keyboard shortcut"""
        logger.info("🎯 NEXT SLIDE command received")
        try:
            # Try multiple methods for next slide
            logger.info("📡 Sending Right Arrow key...")
            pyautogui.press('right')
            logger.info("✅ Right Arrow key sent successfully")
            
            # Alternative method - uncomment if right arrow doesn't work
            # pyautogui.press('space')  # Space bar
            # pyautogui.press('pagedown')  # Page Down
            
        except Exception as e:
            logger.error(f"❌ Error sending next slide command: {e}")
        
    def previous_slide(self):
        """Move to the previous slide using keyboard shortcut"""
        logger.info("🎯 PREVIOUS SLIDE command received")
        try:
            # Try multiple methods for previous slide
            logger.info("📡 Sending Left Arrow key...")
            pyautogui.press('left')
            logger.info("✅ Left Arrow key sent successfully")
            
            # Alternative method - uncomment if left arrow doesn't work
            # pyautogui.press('backspace')  # Backspace
            # pyautogui.press('pageup')  # Page Up
            
        except Exception as e:
            logger.error(f"❌ Error sending previous slide command: {e}")
        
    def start_presentation(self):
        """Start presentation mode using F5 (PowerPoint) or Ctrl+F5 (Google Slides)"""
        logger.info("🎯 START PRESENTATION command received")
        try:
            logger.info("📡 Sending F5 key...")
            pyautogui.press('f5')  # F5 to start slideshow
            logger.info("✅ F5 key sent successfully")
            self.presentation_mode = True
            self.current_slide = 1
            logger.info("🎮 Presentation mode activated")
        except Exception as e:
            logger.error(f"❌ Error starting presentation: {e}")
        
    def end_presentation(self):
        """End presentation mode using Escape key"""
        logger.info("🎯 END PRESENTATION command received")
        try:
            logger.info("📡 Sending Escape key...")
            pyautogui.press('esc')  # Escape to end slideshow
            logger.info("✅ Escape key sent successfully")
            self.presentation_mode = False
            self.current_slide = 0
            logger.info("🛑 Presentation mode deactivated")
        except Exception as e:
            logger.error(f"❌ Error ending presentation: {e}")
    
    def laser_pointer(self):
        """Toggle laser pointer (Ctrl+L in PowerPoint, or mouse control simulation)"""
        logger.info("🔴 LASER POINTER command received")
        try:
            # PowerPoint laser pointer shortcut
            pyautogui.hotkey('ctrl', 'l')
            logger.info("✅ Laser pointer toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling laser pointer: {e}")

    def laser_pointer_move(self, x_percent, y_percent):
        """Move laser pointer to specific screen coordinates based on percentages"""
        self._latest_laser_move = (x_percent, y_percent)
        if self._laser_move_worker_running:
            return

        self._laser_move_worker_running = True
        self._schedule_background_task(self._flush_laser_pointer_moves())

    def _move_laser_pointer(self, x_percent, y_percent):
        screen_width, screen_height = pyautogui.size()
        x = int((x_percent / 100.0) * screen_width)
        y = int((y_percent / 100.0) * screen_height)
        pyautogui.moveTo(x, y, duration=0)

    async def _flush_laser_pointer_moves(self):
        try:
            while self._latest_laser_move is not None:
                x_percent, y_percent = self._latest_laser_move
                self._latest_laser_move = None
                try:
                    await asyncio.to_thread(self._move_laser_pointer, x_percent, y_percent)
                    logger.info(f"🎯 Laser pointer moved to ({x_percent:.1f}%, {y_percent:.1f}%)")
                except Exception as e:
                    logger.error(f"❌ Error moving laser pointer: {e}")
        finally:
            self._laser_move_worker_running = False

    def _schedule_background_task(self, coroutine):
        try:
            loop = asyncio.get_running_loop()
            loop.create_task(coroutine)
        except RuntimeError:
            asyncio.run(coroutine)

    def laser_pointer_click(self, x_percent, y_percent):
        """Click at specific coordinates (useful for highlighting)"""
        try:
            # Get screen dimensions
            screen_width, screen_height = pyautogui.size()
            
            # Convert percentages to actual coordinates
            x = int((x_percent / 100.0) * screen_width)
            y = int((y_percent / 100.0) * screen_height)
            
            # Click at the position
            pyautogui.click(x, y)
            logger.info(f"👆 Laser pointer clicked at ({x}, {y}) - {x_percent:.1f}%, {y_percent:.1f}%")
            
        except Exception as e:
            logger.error(f"❌ Error clicking laser pointer: {e}")
    
    def black_screen(self):
        """Black out the screen (B key in most presentation software)"""
        logger.info("⚫ BLACK SCREEN command received")
        try:
            pyautogui.press('b')  # B key for black screen
            logger.info("✅ Black screen toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling black screen: {e}")
    
    def white_screen(self):
        """White out the screen (W key in most presentation software)"""
        logger.info("⚪ WHITE SCREEN command received")
        try:
            pyautogui.press('w')  # W key for white screen
            logger.info("✅ White screen toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling white screen: {e}")
    
    def presentation_view(self):
        """Toggle presentation view (Alt+F5 or Ctrl+F5)"""
        logger.info("📺 PRESENTATION VIEW command received")
        try:
            pyautogui.hotkey('alt', 'f5')  # Alt+F5 for presenter view
            logger.info("✅ Presentation view toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling presentation view: {e}")
    
    def volume_up(self):
        """Increase system volume"""
        logger.info("🔊 VOLUME UP command received")
        try:
            pyautogui.press('volumeup')
            logger.info("✅ Volume increased")
        except Exception as e:
            logger.error(f"❌ Error increasing volume: {e}")
    
    def volume_down(self):
        """Decrease system volume"""
        logger.info("🔉 VOLUME DOWN command received")
        try:
            pyautogui.press('volumedown')
            logger.info("✅ Volume decreased")
        except Exception as e:
            logger.error(f"❌ Error decreasing volume: {e}")
    
    def mute(self):
        """Toggle system mute"""
        logger.info("🔇 MUTE command received")
        try:
            pyautogui.press('volumemute')
            logger.info("✅ Mute toggled")
        except Exception as e:
            logger.error(f"❌ Error toggling mute: {e}")
    
    def first_slide(self):
        """Go to first slide (Home key)"""
        logger.info("⏮️ FIRST SLIDE command received")
        try:
            pyautogui.press('home')
            logger.info("✅ Moved to first slide")
        except Exception as e:
            logger.error(f"❌ Error going to first slide: {e}")
    
    def last_slide(self):
        """Go to last slide (End key)"""
        logger.info("⏭️ LAST SLIDE command received")
        try:
            pyautogui.press('end')
            logger.info("✅ Moved to last slide")
        except Exception as e:
            logger.error(f"❌ Error going to last slide: {e}")
    
    def full_screen(self):
        """Enter full screen mode (F11)"""
        logger.info("🖥️ FULL SCREEN command received")
        try:
            pyautogui.press('f11')
            logger.info("✅ Entered full screen")
        except Exception as e:
            logger.error(f"❌ Error entering full screen: {e}")
    
    def exit_full_screen(self):
        """Exit full screen mode (F11 or Esc)"""
        logger.info("🖥️ EXIT FULL SCREEN command received")
        try:
            pyautogui.press('f11')  # F11 toggles, or use Esc
            logger.info("✅ Exited full screen")
        except Exception as e:
            logger.error(f"❌ Error exiting full screen: {e}")
        
    def handle_command(self, command, params=None):
        """Handle incoming commands from the mobile app"""
        command_map = {
            'next': self.next_slide,
            'previous': self.previous_slide,
            'start_presentation': self.start_presentation,
            'end_presentation': self.end_presentation,
            'laser_pointer': self.laser_pointer,
            'laser_pointer_move': self.laser_pointer_move,
            'laser_pointer_click': self.laser_pointer_click,
            'black_screen': self.black_screen,
            'white_screen': self.white_screen,
            'presentation_view': self.presentation_view,
            'volume_up': self.volume_up,
            'volume_down': self.volume_down,
            'mute': self.mute,
            'first_slide': self.first_slide,
            'last_slide': self.last_slide,
            'full_screen': self.full_screen,
            'exit_full_screen': self.exit_full_screen,
        }
        
        if command in command_map:
            try:
                # Handle commands that need parameters
                if command in ['laser_pointer_move', 'laser_pointer_click'] and params:
                    x_percent = params.get('x_percent', 50)
                    y_percent = params.get('y_percent', 50)
                    command_map[command](x_percent, y_percent)
                else:
                    command_map[command]()
                return {'status': 'success', 'command': command}
            except Exception as e:
                logger.error(f"Error executing command {command}: {e}")
                return {'status': 'error', 'message': str(e)}
        else:
            return {'status': 'error', 'message': f'Unknown command: {command}'}

class SlideControllerServer:
    def __init__(self, host='0.0.0.0', port=8080):
        self.host = host
        self.port = port
        self.controller = SlideController()
        self.connected_clients = set()
        
    def get_local_ip(self):
        """Get the local IP address of the machine"""
        try:
            # Connect to a remote address to determine local IP
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.connect(("8.8.8.8", 80))
                local_ip = s.getsockname()[0]
                return local_ip
        except Exception:
            return "localhost"
    
    async def handle_client(self, websocket, path):
        """Handle WebSocket connections from mobile clients"""
        client_address = websocket.remote_address
        logger.info(f"New client connected: {client_address}")
        self.connected_clients.add(websocket)
        
        try:
            # Send welcome message
            welcome_message = {
                'type': 'welcome',
                'message': 'Connected to Slide Controller Server',
                'server_info': {
                    'version': '1.0.0',
                    'presentation_mode': self.controller.presentation_mode,
                    'current_slide': self.controller.current_slide
                }
            }
            await websocket.send(json.dumps(welcome_message))
            
            async for message in websocket:
                try:
                    data = json.loads(message)
                    logger.info(f"Received message from {client_address}: {data}")
                    
                    if 'command' in data:
                        command = data['command']
                        params = data.get('params', {})
                        response = self.controller.handle_command(command, params)
                        response['timestamp'] = data.get('timestamp')
                        await websocket.send(json.dumps(response))
                        
                        # Broadcast status to all connected clients
                        if response['status'] == 'success':
                            status_update = {
                                'type': 'status_update',
                                'presentation_mode': self.controller.presentation_mode,
                                'current_slide': self.controller.current_slide,
                                'last_command': data['command']
                            }
                            await self.broadcast_to_clients(status_update, exclude=websocket)
                    
                except json.JSONDecodeError:
                    error_response = {'status': 'error', 'message': 'Invalid JSON format'}
                    await websocket.send(json.dumps(error_response))
                except Exception as e:
                    error_response = {'status': 'error', 'message': str(e)}
                    await websocket.send(json.dumps(error_response))
                    logger.error(f"Error handling message: {e}")
                    
        except ConnectionClosed:
            logger.info(f"Client {client_address} disconnected")
        except Exception as e:
            logger.error(f"Error with client {client_address}: {e}")
        finally:
            self.connected_clients.discard(websocket)
            
    async def broadcast_to_clients(self, message, exclude=None):
        """Broadcast a message to all connected clients"""
        if not self.connected_clients:
            return
            
        message_str = json.dumps(message)
        disconnected_clients = set()
        
        for client in self.connected_clients:
            if client == exclude:
                continue
                
            try:
                await client.send(message_str)
            except ConnectionClosed:
                disconnected_clients.add(client)
            except Exception as e:
                logger.error(f"Error broadcasting to client: {e}")
                disconnected_clients.add(client)
        
        # Remove disconnected clients
        self.connected_clients -= disconnected_clients
    
    async def start_server(self):
        """Start the WebSocket server"""
        local_ip = self.get_local_ip()
        
        logger.info("=" * 60)
        logger.info("🎯 SLIDE CONTROLLER SERVER STARTING")
        logger.info("=" * 60)
        logger.info(f"📱 Server running on: {local_ip}:{self.port}")
        logger.info(f"🌐 WebSocket URL: ws://{local_ip}:{self.port}")
        logger.info("=" * 60)
        logger.info("📋 POWERPOINT SETUP INSTRUCTIONS:")
        logger.info("1. 📊 Open PowerPoint presentation")
        logger.info("2. 🖱️ Click on the PowerPoint window to make it active")
        logger.info("3. 📱 Connect your phone using the IP above")
        logger.info("4. 🎮 Tap 'Start' in the app to begin slideshow (F5)")
        logger.info("5. 👆 Swipe left/right to control slides")
        logger.info("=" * 60)
        logger.info("🔧 TROUBLESHOOTING TIPS:")
        logger.info("• Make sure PowerPoint window is in FOCUS (click on it)")
        logger.info("• Start slideshow mode first (F5 or Start button)")
        logger.info("• Test manually: F5 → Right Arrow → Left Arrow → Esc")
        logger.info("• If not working, try closing other programs")
        logger.info("=" * 60)
        logger.info("🎮 KEYBOARD SHORTCUTS USED:")
        logger.info("• F5: Start presentation")
        logger.info("• Esc: End presentation")
        logger.info("• Right Arrow: Next slide")
        logger.info("• Left Arrow: Previous slide")
        logger.info("=" * 60)
        logger.info("Press Ctrl+C to stop the server")
        logger.info("=" * 60)
        
        async with serve(self.handle_client, self.host, self.port):
            logger.info("🚀 Server started successfully!")
            await asyncio.Future()  # Run forever

def main():
    """Main function to start the server"""
    server = SlideControllerServer()
    
    try:
        asyncio.run(server.start_server())
    except KeyboardInterrupt:
        logger.info("\n" + "=" * 60)
        logger.info("🛑 Server stopped by user")
        logger.info("=" * 60)
    except Exception as e:
        logger.error(f"Server error: {e}")

if __name__ == "__main__":
    main()
