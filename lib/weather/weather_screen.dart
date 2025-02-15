import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

import 'secrets.dart';

import './weather_forcast_cart.dart';
import './weather_additional_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    // getting Current City name
    String cityName = 'Lakshmipur';
    http.Client client = http.Client();

    try {
      final res = await client.get(
        Uri.parse(
          '$apiLink?q=$cityName&APPID=$weatherKey',
        ),
      );

      final data = await jsonDecode(res.body);
//      if (data['cod'] != '200') {
//        throw 'An unexpected error occured';
//      }

      //  data['list'][0]['main']['temp'];
      return data;
    } catch (e) {
      throw 'Unable to get weather data: ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "EIGFA Weather",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator(
              color: Color(0xFFA7A7A7),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final num currentTemp = data['list'][0]['main']['temp'] - 273.15;
          final currentSky = data['list'][0]['weather'][0]['main'];
          final humidity = data['list'][0]['main']['humidity'];
          final pressure = data['list'][0]['main']['pressure'];
          final windSpeed = data['list'][0]['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  ----------------------------------------------------------------  Main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                //  Print Main value
                                '${currentTemp.toStringAsFixed(2)}° C',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Icon(
                                Icons.cloud,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                //  ------------------------------------------------- Weather Forecast Sections
                const Text(
                  "Hourly Forcast",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),

                //  ---------------------------------------- Weather Forecast Cards

                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: 8,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForcast = data['list'];
                      final hourlySky =
                          hourlyForcast[index]['weather'][0]['main'];
                      final time =
                          DateTime.parse(hourlyForcast[index]['dt_txt']);
                      return WeatherForcast(
                        time: DateFormat.j().format(time),
                        icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        value: hourlyForcast[index]['main']['temp'],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                //  --------------------------------------------------- Additional Informations
                const Text(
                  "Additional Information",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WeatherAdditionalInfo(
                        icon: Icons.water_drop,
                        lebel: 'Humidity',
                        value: humidity,
                      ),
                      WeatherAdditionalInfo(
                        icon: Icons.air,
                        lebel: 'Wind Speed',
                        value: windSpeed,
                      ),
                      WeatherAdditionalInfo(
                        icon: Icons.speed,
                        lebel: 'Pressure',
                        value: pressure,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${data['city']['name']}, ${data['city']['country']}',
                  style: const TextStyle(
                    color: Color(0xaaaaaaaa),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
