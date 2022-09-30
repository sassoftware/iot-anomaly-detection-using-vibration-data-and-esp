# Detecting Industrial Equipment Anomalies using SAS ESP

## Table of Contents

* [Overview](#overview)
* [Objective](#objective)
* [Prerequisites](#prerequisites)
* [Steps](#steps)
	* [1. DAQ configuration](#1.-daq-configuration)
	* [2. ESP on Edge Analytics](#2.-esp-on-edge-analytics)
	* [3. ESP Model](#3.-esp-model)
* [Contributing](#contributing)
* [License](#license)
* [Additional Resources](#additional-resources)



## Overview

This simple demonstration was developed to show how anomaly detection works using real-time vibration data and SAS Event Stream Processing (ESP). Input data is flowing by way of MQTT at a rate of 12.8 kHz with RMSA calculated every second. After that, an SVDD model is used for scoring. (Note: The SVDD model was trained using SAS Studio) As shown in the video below, the team built a device with two rotating fans (one with a normal fan and another with a blade broken) and used SVDD to detect when the condition of the machine (fan) changes. The output is SVDD distance (top graph) and SVDD score (bottom graph). When the normal fan is rotating, the score is -1 (normal state) but when the device is switched to the broken fan, the SVDD score changes to 1 (faulty state).   

[![Simple Fan Device](/images/fan2.png)](
http://sas-social.brightcovegallery.com/sharing?videoId=6313064583112
 "Simple Fan Device")
 
## Objective
The objective of the demo is to illustrate ESP's capabilities in the field of machine-condition monitoring and condition-based maintenance. The team prepared a simple fan device, shown below, which can be switched between normal and failure modes. An accelerometer is attached to gather the vibration data and send to an ADLink USB-2405 DAQ. (Note: Alternatively, you can use an ADLink MCM-100 DAQ (edge device) which is basically a DAQ device and a PC) 

![FAN](/images/Fan.png "FAN")

As mentioned above, the device has one normal fan and one broken blade as shown below. 

![FAN](/images/Fan2.png "FAN Model")

You can refer to the circuit diagram below for more information and for the list of required components to make the fan failure simulator. For more information please refer to this [video](http://sas-social.brightcovegallery.com/sharing?videoId=6313068435112) or [pdf](https://gitlab.sas.com/IOT/demos/anomaly-detection-using-esp/-/blob/master/fan%20simulator/Fan_Failure_Simulator.pdf).

![Circuit Diagram!](/images/CircuitDiagram.png "Circuit Diagram")

The team used an ADLink MCM-100 to collect the vibration data through one of the four channels. Since it's an edge device, you can deploy ESP (edge) on it.

![MCM-100!](/images/MCM-100.png "MCM-100")

Here is the system diagram for the anomaly detection demo. In our case, the monitoring target on the far-left side becomes the fan shown above. The USB-2405 is a 24-bit high-performance dynamic signal acquisition USB module equipped with four analog input channels providing simultaneous sampling at up to 128 kS/s per channel. The USB-2405 also features software selectable AC or DC coupling input configuration and built-in high precision 2 mA excitation current to measure integrated electronic piezoelectric (IEPE) sensors such as accelerometers and microphones. For more information on the DAQ, please refer to this [link](https://www.adlinktech.com/Products/Data_Acquisition/USBDAQ/USB-2405?lang=en#tab-36812). One thing we should keep in mind is that the DAQ (USB-2405 or MCM-100) only have drivers available for specific versions of Linux OS with limited kernel versions supported.  

![System Diagram!](/images/SystemDiagram.png "System Diagram")

This demo is based on the paper [Condition-Based Monitoring Using SAS® Event Stream Processing](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2019/3141-2019.pdf) that was written by our colleagues in the US. We only applied time-based analysis by calculating the RMSA for the 12,800 samples every second. When monitoring vibration, the root mean square amplitude (RMSA) of the signal is often tracked.

![RMSA!](/images/RMSA.png "RMSA")

The SVDD model was trained separately using SAS Studio with three-minute long RMSA data taken at different rotation speeds (RPM). The parameters for the SVDD algorithm were set to automatic with RBF bandwidth parameter 0.3.  

## Prerequisites
List of required hardware:
- [Simple fan device](http://sas-social.brightcovegallery.com/sharing?videoId=6313068435112)
- ADLink data acquisition device (DAQ) to collect the vibration data from sensors (USB-2405 or MCM-100)
- Accelerometer sensor
- Edge device (ADLink MCM-100)

List of required software
- Driver for the DAQ
- MQTT Client - Mosquitto
- ESP on Edge with analytics
- ESP Stremviewer or [esp-connect](https://gitlab.sas.com/roleve/esp-connect) api for monitoring 

## Steps
### 1. DAQ configuration
You need to make sure you have the necessary driver. You'll need to create an account to download the driver for your OS version. It's important to ensure you have the specific kernel version for your OS for the driver to work. For our case, we downloaded and set up the driver for Ubuntu 18.04 with kernel 4.15.0-20-generic "UD-DASK/X, v21.03 for Ubuntu 18.04 & 20.04 (4.15.0-20-generic, 5.4.0-26-generic, 5.4.0-47-generic)". You can download the driver from this [link](https://www.adlinktech.com/Products/DownloadSoftware?lang=en&pdNo=1710&MainCategory=Edge-IoT-Solutions-and-Technology&kind=DR).

Once you are done downloading the drivers, you'll have a folder with the same contents as the ad-link folder in this repo. We updated the sample code written in C language (refer to the [c-code](https://gitlab.sas.com/IOT/demos/anomaly-detection-using-esp/-/blob/master/ad-link/ud-dask/samples/2405/c2405_AI_DMA_Sync/2405ai.c)). You need to first run the make file. Make sure you have installed all the necessary libraries like MQTT broker. Once everything is setup and MQTT broker is started, you just need to run the following three commands to start data acquisition. This 2405.c code is set to acquire 6400 samples per second and send it to esp via MQTT. You can change this value at line 16 for AI_COUNT.
```
 # cd ~/ad-link\ud-dask\samples\2405\c2405_AI_DMA_Sync\
 # make
 # ./2405
```
### 2. ESP on Edge Analytics
We'll be using docker images for our ESP deployment. We pulled the latest docker image from the internal [repo](https://repulpmaster.unx.sas.com/v2/cdp-release-x64_oci_linux_2-docker-latest/sas-esp-server-edge-analytics/). Since we'll be using astore analysis, we pulled the ESP edge with analytics. You can refer to the Word file here on how to configure your ESP. You can also pull ESP Studio and Steamviewer to visualize the model. You will need to enable MQTT and you'll need MQTT library libmosquitto.so.1. You can refer to the Word [file](https://gitlab.sas.com/IOT/demos/anomaly-detection-using-esp/-/blob/master/esp/Working_with_ESP_docker.docx) for more details.

### 3. ESP Model
We made a simple [model.xml]() consisting of a source window with mqtt connector, a calculate window to calculate the RMSA, a model reader for the SVDD model and a score window for the SVDD score at the end. You can use the csv files included in the 'esp' folder to test the SVDD model. There are two csv files included. One is the data for nomal condition and the other for failure state. Make sure you change the input data connector to csv in model.xml. The 'SVDD_Model_RMSA_Stoch.sasast' is the astore file for the SVDD model.  

![Model!](/images/model.png "Model")

## Contributing

This project is not accepting contributions

## License

> This project is licensed under the [SAS License Agreement for Corrective Code or Additional Functionality](LICENSE).

## Additional Resources
- [SAS Event Stream Processing 2021.1.5 Documentation](https://go.documentation.sas.com/doc/en/espcdc/v_014/espwlcm/home.htm)
- [Six hints for improving sensor data quality](https://communities.sas.com/t5/SAS-Communities-Library/Six-hints-for-improving-sensor-data-quality/ta-p/813677)
- [Why data quality really matters in analyzing sensor data](https://communities.sas.com/t5/SAS-Communities-Library/Why-data-quality-really-matters-in-analyzing-sensor-data/ta-p/813657)
