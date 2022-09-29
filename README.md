# Detecting Industrial Equipment Anomalies using SAS ESP

## Overview

This is a simple demo to demonstrate anomaly detection using a real-time vibration data and SAS ESP. Input data is flowing in via MQTT at a rate of 12.8 kHz. Then we calculate RMSA every second. After that, SVDD model for is used for scoring. The SVDD model was trained using separately on SAS Studio. As shown in the video below, we made a  device with 2 rotating fans (one with normal fan and another with a blade broken) and used SVDD to detect when the condition of the machine (fan) changes. The output is SVDD distance (top graph) and SVDD score (bottom graph). When the normal fan is rotating, the score is -1 (normal state) but when the device is switched to the broken fan, the SVDD score changes to 1 (faulty state).   

<Insert Brightcove Video>

## Objective
The goal of this demo is to show ESP's capabilities in the field of machine condition monitoring and condition-based maintenance. We prepared a simple fan device shown below, which we can switch between normal and failure modes. We attached an accelerometer to gather the vibration data and it was collected by ADLink USB-2405 DAQ. It is also possible to use ADLink MCM-100 DAQ (edge device) which is basically a DAQ device and also a PC. 

![FAN](/images/Fan.png "FAN")

As mentioned above, the device we prepared for this demo has one normal fan and another one with a broken blade as shown below. 

![FAN](/images/Fan2.png "FAN Model")

You can refer to the circuit diagram below for more information and for the list of required components to make the fan failure simulator. For more information please refer to this [pdf](https://gitlab.sas.com/IOT/demos/anomaly-detection-using-esp/-/blob/master/fan%20simulator/Fan_Failure_Simulator.pdf).

![Circuit Diagram!](/images/CircuitDiagram.png "Circuit Diagram")

We used ADLink MCM-100 to collect the vibration data through one of the 4 channels. Since it's an edge device, you can deploy ESP (edge) on it.

![MCM-100!](/images/MCM-100.png "MCM-100")

Here is the system diagram for this anomaly detection demo. For our case, the monitoring target on the far-left side becomes the fan shown above. The USB-2405 is a 24-bit high-performance dynamic signal acquisition USB module equipped with 4 analog input channels providing simultaneous-sampling at up to 128 kS/s per channel. The USB-2405 also features software selectable AC or DC coupling input configuration and built-in high precision 2 mA excitation current to measure integrated electronic piezoelectric (IEPE) sensors such as accelerometers and microphones. For more information on the DAQ, please refer to this [link](https://www.adlinktech.com/Products/Data_Acquisition/USBDAQ/USB-2405?lang=en#tab-36812). One thing we should keep in mind is that the DAQ (USB-2405 or MCM-100) only have drivers available for specific versions of Linux OS with limited kernel versions supported.  

![System Diagram!](/images/SystemDiagram.png "System Diagram")

This demo is based on the paper [Condition-Based Monitoring Using SAS® Event Stream Processing](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2019/3141-2019.pdf) that was written by our colleagues in the US. We only applied time-based analysis by calculating the RMSA for the 12,800 samples every second. When monitoring vibration, the root mean square amplitude (RMSA) of the signal is often tracked.

![RMSA!](/images/RMSA.png "RMSA")

The SVDD model was trained separately using SAS studio with a 3 minute long RMSA data taken at different rotation speed (RPM). The parameter for the SVDD algorithm were set to automatic with RBF bandwidth parameter 0.3.  

## Prerequisites
List of required hardware:
- Simple fan device
- ADLink data acquisition device (DAQ) to collect the vibration data from sensors (USB-2405 or MCM-100)
- Accelerometer sensor
- Edge device (ADLink MCM-100)

List of required software
- Driver for the DAQ
- Mqtt Client - Mosquitto
- ESP on Edge with analytics
- ESP stremviewer or [esp-connect](https://gitlab.sas.com/roleve/esp-connect) api for monitoring 

## Steps
### 1. DAQ configuration
You need to make sure you have the necessary driver that is needed to start. You'll need to create an account to download the driver for your OS version. It's important to make sure you have the specific kernel version for your OS for the driver to work. For our case, we downloaded and set up the driver for Ubuntu 18.04 with kernel 4.15.0-20-generic "UD-DASK/X, v21.03 for Ubuntu 18.04 & 20.04 (4.15.0-20-generic, 5.4.0-26-generic, 5.4.0-47-generic)". You can download the driver from this [link](https://www.adlinktech.com/Products/DownloadSoftware?lang=en&pdNo=1710&MainCategory=Edge-IoT-Solutions-and-Technology&kind=DR).

Once you are done downloading the drivers you'll have a folder with the same contents as the ad-link folder in this repo. We updated the sample code written in C language (refer to the [c-code](https://gitlab.sas.com/IOT/demos/anomaly-detection-using-esp/-/blob/master/ad-link/ud-dask/samples/2405/c2405_AI_DMA_Sync/2405ai.c)). You need to first run the make file. Make sure you have installed all the necessary libraries like mqtt broker. Once everything is setup and mqtt broker is started, you just need to run the following 3 commands to start data acquisition. This 2405.c code is set to acquire 6400 samples per sec and send it to esp via mqtt. You can change this value at line 16 for AI_COUNT.
```
 # cd ~/ad-link\ud-dask\samples\2405\c2405_AI_DMA_Sync\
 # make
 # ./2405
```
### 2. ESP on Edge Analytics
We'll be using docker images for our esp deployment. We pulled the latest docker image from the internal [repo](https://repulpmaster.unx.sas.com/v2/cdp-release-x64_oci_linux_2-docker-latest/sas-esp-server-edge-analytics/). Since we'll be using astore analysis, we pulled the esp edge with analytics. You refer to the word file here on how to configure your esp. You can also pull esp studio and steamviewer to visualize the model. You will need to enable mqtt and you'll need mqtt library libmosquitto.so.1. You can refer to the word [file](https://gitlab.sas.com/IOT/demos/anomaly-detection-using-esp/-/blob/master/esp/Working_with_ESP_docker.docx) for more details.

### 3. ESP Model
We made a simple [model.xml]() consisting of a source window with mqtt connector, a calculate window to calculate the RMSA, a model reader for the SVDD model and a score window for the SVDD score at the end. You can use the csv files included in the 'esp' folder to test the SVDD model. There are 2 csv files included. One is the data for nomal condition and the other for failure state. Make sure you change the input data connector to csv in model.xml. The 'SVDD_Model_RMSA_Stoch.sasast' is the astore file for the SVDD model.  

![Model!](/images/model.png "Model")

## Contributing

This project is not accepting contributions

## License

> This project is licensed under the [SAS License Agreement for Corrective Code or Additional Functionality](LICENSE).

## Additional Resources
- [SAS Event Stream Processing 2021.1.5 Documentation](https://go.documentation.sas.com/doc/en/espcdc/v_014/espwlcm/home.htm)
- [Six hints for improving sensor data quality](https://communities.sas.com/t5/SAS-Communities-Library/Six-hints-for-improving-sensor-data-quality/ta-p/813677)
- [Why data quality really matters in analyzing sensor data](https://communities.sas.com/t5/SAS-Communities-Library/Why-data-quality-really-matters-in-analyzing-sensor-data/ta-p/813657)
