#!/usr/bin/python3

from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
import time
import yaml
import mouse

mouse.move(0, 0)

with open("vars.yml", "r") as stream:
	v = yaml.safe_load(stream)

with open("config.yml", "r") as stream:
	c = yaml.safe_load(stream)

driver = webdriver.Firefox()
driver.get("http://db.open5gs.int")


# Login	
WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "/html/body/div[1]/div/div[1]/div/div/div/div[2]/div[1]/input")).send_keys("admin")
WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "/html/body/div[1]/div/div[1]/div/div/div/div[2]/div[2]/input")).send_keys("1423" + Keys.RETURN)

# Create subscribers:
for s in c["subscribers"]:
	try:
		time.sleep(1)
		
		try:
			WebDriverWait(driver,2).until(lambda driver: driver.find_element(By.XPATH, "/html/body/div[1]/div/div[1]/div/div/div/div[2]/div[2]/div/div[2]/div[3]")).click()
		except:
			WebDriverWait(driver,2).until(lambda driver: driver.find_element(By.XPATH, "/html/body/div[1]/div/div[1]/div/div/div/div[2]/div[2]/div/div[3]")).click()

		WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_imsi\"]")).clear()
		WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_imsi\"]")).send_keys(str(s["imsi"]))
		WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_security_k\"]")).clear()
		WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_security_k\"]")).send_keys(str(s["key"]))
		WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_security_op_value\"]")).clear()
		WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_security_op_value\"]")).send_keys(str(s["op"]) + Keys.RETURN)
	except:
		pass 
		#try:
			#time.sleep(1)
			#WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "/html/body/div[1]/div/div[1]/div/div/div/div[2]/div[1]/div[1]/div[2]")).click()
			#time.sleep(1)
			#WebDriverWait(driver,150).until(lambda driver: driver.find_element_by_css_selector(".gptr28-0 > svg:nth-child(1) > g:nth-child(1) > path:nth-child(1)")).click()
			#time.sleep(1)
			#WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_imsi\"]")).send_keys(str(s["imsi"]))
			#time.sleep(1)
			#WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_security_k\"]")).send_keys(str(s["key"]))
			#time.sleep(1)
			#WebDriverWait(driver,150).until(lambda driver: driver.find_element(By.XPATH, "//*[@id=\"root_security_op_value\"]")).send_keys(str(s["op"]) + Keys.RETURN)		
			#time.sleep(1)
		#except:
		#	pass


