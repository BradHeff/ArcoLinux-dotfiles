#!/usr/bin/env python

import os
import re
import subprocess

	
class wifi(object):

	def __init__(self):
		super(wifi, self).__init__()
        
		try:
			result = subprocess.check_output(("nmcli", "d", "wifi", "list"))
			lines = len(result.decode().split("\n"))
			selection = self.show_menu("Wifi Menu", result.decode(), lines)			
			self.connect(selection)
		except:
			exit(0)
            

	def show_menu(self, TITLE, ITEMS, LINES):
		items = subprocess.Popen(('echo', ITEMS), stdout=subprocess.PIPE)
		output = subprocess.check_output(("rofi", "-width", "-30", "-location", "3", "-bw", "2", "-dmenu", "-i", "-p", TITLE, "-lines", str(LINES)), stdin=items.stdout)
		return output.decode().strip()
	
	def connect(self, SSID):
		items = subprocess.Popen(('nmcli', '-f', 'device,type', 'd'), stdout=subprocess.PIPE)
		device = subprocess.check_output(('grep', 'ethernet'), stdin=items.stdout)
		result = device.decode().strip().split(" ")
		
		con = subprocess.check_output(("nmcli", "d", "connect", result[0]))

		if "activated" in con.decode():
			output = subprocess.check_output(("rofi", "-width", "-30", "-location", "0", "-bw", "2", "-dmenu", "-i", "-p", "Password", "-lines", "0"))

			con = subprocess.check_output(("nmcli", "d", "wifi", "connect", SSID, "password", output.decode(), "iface", result[0]))
			self.show_notify(result[0])


	def show_notify(self, selection):
		ICON = "messagebox_info"
		command = ' '.join(["notify-send", "-u", "normal", "-i", ICON, '"' + selection + '" ' + '"Successfully activated"'])
		os.system(command.strip())


if __name__ == '__main__':
	wifi()