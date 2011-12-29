package com.nycresistor.processing;

import processing.core.*;
import processing.net.*;
import processing.serial.*;

/**
 * Provides an interface onto a real or virtual SpookyBox device
 * @author justin
 */
public class SpookyBox {
	public static final int PROTOCOL_VERSION = 2;
	public static final int SERIAL = 1;
	public static final int NETWORK = 2;
	public static final int FRAME_RATE_DIVISOR = 10;
	public static final int REFRESH_RATE = 1000;

	PApplet parent = null;
	Client client = null;
	Serial serial = null;
	byte[] buffer = new byte[1024];
	
	int knob1 = 0;
	int knob2 = 0;
	int knob3 = 0;
	boolean button1 = false;
	boolean button2 = false;
	boolean button3 = false;
	boolean button4 = false;
	boolean buttonPressed1 = false;
	boolean buttonPressed2 = false;
	boolean buttonPressed3 = false;
	boolean buttonPressed4 = false;
	
	int frameSkip = 0;
	float frameRate = 0;
	
	/**
	 * Connects to a SpookyBox and begins receiving data.
	 * @param parent The applet (this)
	 * @param method Either SpookyBox.SERIAL for serial connections, or SpookyBox.NETWORK for network connections
	 * @param serverOrSerialPort If using SERIAL, the name of the serial port to use.  If using NETWORK, the server address to use.
	 * @param serverPortOrBaudRate If using SERIAL, the baud rate to use.  If using NETWORK, the TCP port number to connect to.
	 */
	public SpookyBox(PApplet parent, int method, String serverOrSerialPort, int serverPortOrBaudRate) {
		this.parent = parent;
		
		if (method == SERIAL) {
			serial = new Serial(parent, serverOrSerialPort, serverPortOrBaudRate);
		}
		else {
			client = new Client(parent, serverOrSerialPort, serverPortOrBaudRate);
		}
		
		if (PROTOCOL_VERSION == 2) {
			sendRequestForRefresh();
		}
		
		parent.registerDispose(this);
		parent.registerPre(this);
	}
	
	/**
	 * Connects to a SpookyBox and begins receving data.   If the method given is SERIAL, the first SerialPort available will be tried at 9600 baud.
	 * If method given is NETWORK, the client will connect to localhost on port 5204.
	 * @param parent The applet (this)
	 * @param method Either SpookyBox.SERIAL for serial connections, or SpookyBox.NETWORK for network connections
	 */
	public SpookyBox(PApplet parent, int method) {
		this.parent = parent;
		
		if (method == SERIAL) {
			serial = new Serial(parent, Serial.list()[0], 9600);
		}
		else {
			client = new Client(parent, "localhost", 5204);
		}

		if (PROTOCOL_VERSION == 2) {
			sendRequestForRefresh();
		}
		
		parent.registerDispose(this);
		parent.registerPre(this);		
	}
	
	/**
	 * Called when your applet closes to clean up.
	 */
	public void dispose() {
		if (client != null)
			client.stop();
		
		if (serial != null)
			serial.stop();
	}

	/**
	 * Returns the value of Knob 1
	 * @return A number between 0-1024
	 */
	public int getKnob1() {
		return knob1;
	}
	
	/**
	 * Returns the value of Knob 2
	 * @return A number between 0-1024
	 */
	public int getKnob2() {
		return knob2;
	}

	/**
	 * Returns the value of Knob 3
	 * @return A number between 0-1024
	 */
	public int getKnob3() {
		return knob3;
	}

	/**
	 * Returns true if button 1 is being pressed
	 * @return True if button is being pressed
	 */
	public boolean isButton1() {
		return button1;
	}

	/**
	 * Returns true if button 2 is being pressed
	 * @return True if button is being pressed
	 */
	public boolean isButton2() {
		return button2;
	}

	/**
	 * Returns true if button 3 is being pressed
	 * @return True if button is being pressed
	 */
	public boolean isButton3() {
		return button3;
	}

	/**
	 * Returns true if button 4 is being pressed
	 * @return True if button is being pressed
	 */
	public boolean isButton4() {
		return button4;
	}
	
	private void setButton1(boolean value) {
		if (!value && button1) {
			buttonPressed1 = true;
		}
		button1 = value;
	}
	
	private void setButton2(boolean value) {
		if (!value && button2) {
			buttonPressed2 = true;
		}
		button2 = value;
	}
	
	private void setButton3(boolean value) {
		if (!value && button3) {
			buttonPressed3 = true;
		}
		button3 = value;
	}
	
	private void setButton4(boolean value) {
		if (!value && button4) {
			buttonPressed4 = true;
		}
		button4 = value;
	}
	
	/**
	 * Returns true once if button1 was pressed and released.
	 */
	public boolean wasButton1() {
		boolean result = buttonPressed1;
		buttonPressed1 = false;
		return result;
	}
	
	/**
	 * Returns true once if button2 was pressed and released.
	 */
	public boolean wasButton2() {
		boolean result = buttonPressed2;
		buttonPressed2 = false;
		return result;
	}
	
	/**
	 * Returns true once if button3 was pressed and released.
	 */
	public boolean wasButton3() {
		boolean result = buttonPressed3;
		buttonPressed3 = false;
		return result;
	}
	
	/**
	 * Returns true once if button4 was pressed and released.
	 */
	public boolean wasButton4() {
		boolean result = buttonPressed4;
		buttonPressed4 = false;
		return result;
	}
	
	/**
	 * Called when entering a frame.  Checks for and reads any new data.
	 */
	public void pre() {
		if (frameRate != parent.frameRate) {
			frameSkip = (int)Math.floor(parent.frameRate/10);
			if (frameSkip < 1)
				frameSkip = 1;
			
			frameRate = parent.frameRate;
		}
		if (parent.frameCount % frameSkip == 0) {
			parseData(readData());
		}
		
		if (PROTOCOL_VERSION == 2 && parent.frameCount % REFRESH_RATE == 0) {
			sendRequestForRefresh();
		}
	}

	/**
	 * Reads data from serial or network
	 * @return Number of bytes read
	 */
	private int readData() {
		if (client != null) {
			if (client.available() > 0) {
				return client.readBytes(buffer);
			}
		}
		else {
			if (serial.available() > 0) {
				return serial.readBytes(buffer);
			}
		}
		
		return 0;
	}
	
	private void sendRequestForRefresh() {
		if (client != null) {
			client.write((char)255);
		}
		else {
			serial.write((char)255);
		}
	}
	
	/**
	 * Parses the data into usable information.
	 * @param bytesRead
	 */
	private void parseData(int bytesRead) {
		if (bytesRead > 0) {
			/*for (int i=0; i<bytesRead; i++) {
				PApplet.print(unsignByte(buffer[i]));
				PApplet.print(" ");
			}
			PApplet.println();*/
			int dataOffset = findDataOffet(buffer,bytesRead);       
			if (dataOffset != -1) {
				parseVersion1Protocol(dataOffset);
			}
			// Must be a version two packet
			else {
				parseVersion2Protocol(bytesRead);
			}
		}
	}

	private void parseVersion1Protocol(int dataOffset) {
		//for (int i=dataOffset-3; i<dataOffset+10; i++) {
		//	PApplet.print(unsignByte(buffer[i]));
		//	PApplet.print(" ");
		//}
		//PApplet.println();
		
		
		knob1 = extractInt(buffer,dataOffset);
		knob2 = extractInt(buffer,dataOffset+2);
		knob3 = extractInt(buffer,dataOffset+4);
		setButton1(extractBoolean(buffer,dataOffset+6));
		setButton2(extractBoolean(buffer,dataOffset+7));
		setButton3(extractBoolean(buffer,dataOffset+8));
		setButton4(extractBoolean(buffer,dataOffset+9));		
	}
	
	private void parseVersion2Protocol(int bytesRead) {
		int b;
		for(int i=0; i<bytesRead; i++) {
			b = unsignByte(buffer[i]);
			
			if (isButtonUpdate(b)) {
				setButton1(extractBoolean(b,3));
				setButton2(extractBoolean(b,2));
				setButton3(extractBoolean(b,1));
				setButton4(extractBoolean(b,0));
			}
			else if (isKnobUpdate(b) && i<bytesRead) {
				int n = extractKnobNumber(b);
				int d = extractKnobData(b,unsignByte(buffer[i+1]));
				
				boolean result = (d % 2) != ((b & 0x40)>>6);
				
				if (result) {
					assignKnobData(n,d);
				}
				
				i++;
			}
		}
	}

	/**
	 * Finds the beginning of the data by looking for 3 bytes in a row that are 255.  Because the knobs can only read 0-1024
	 * and the buttons can only read 0-1 it should only be possible to get three 255's from this signature.
	 * @param buffer
	 * @param bytes
	 * @return
	 */
	private int findDataOffet(byte[] buffer, int bytes) {
		int matches = 0;

		for (int i=0; i<bytes; i++) {
			if (buffer[i] == -1) {
				matches++;
			}
			else {
				matches = 0;
			}

			if (matches == 3) {
				if (bytes-i >= 10) {
					return i + 1;
				}
			}
		}

		return -1;
	}

	/**
	 * Extracts an integer from two bytes.  Assumes bytes are 16-bit big endian.
	 * @param buffer
	 * @param offset
	 * @return
	 */
	private int extractInt(byte[] buffer, int offset) {
		int result = buffer[offset] << 8;
		
		// Why oh why would you want to sign a byte?
		if (buffer[offset+1] < 0) {
			result += (buffer[offset+1] + 256);
		}
		else {
			result += buffer[offset+1];
		}

		return result;
	}

	/**
	 * Extracts a boolean from a single byte.
	 * @param buffer
	 * @param offset
	 * @return
	 */
	private boolean extractBoolean(byte[] buffer, int offset) {
		return buffer[offset] != 0;
	}
	
	private boolean extractBoolean(int b, int bit) {
		return (b & (1 << bit)) != 0;
	}
	
	private boolean isButtonUpdate(int b) {
		if ((b & 176) != 176) {
			return false;
		}
		
		boolean result = ((b & 0xF) % 2) != ((b & 0x40)>>6);
				
		return result;
	}
	
	private boolean isKnobUpdate(int b) {
		if ((b & 128) != 128)
			return false;
		
		return true;	
	}
	
	private int extractKnobNumber(int b) {
		int n = (b & 48);
		return n >> 4;
	}
	
	private int extractKnobData(int high, int low) {
		int n = ((high & 7) << 7) + low;
		return n;
	}
	
	private void assignKnobData(int n, int value) {
		if (n == 0)
			knob1 = value;
		else if (n == 1)
			knob2 = value;
		else if (n == 2)
			knob3 = value;
	}
	
	private int unsignByte(byte b) {
		if (b<0) {
			return 256 + b;
		}
		else {
			return b;
		}
	}
}
