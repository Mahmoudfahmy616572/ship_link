// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

import '../../../../../data/models/cities_models.dart';
import '../../../../../data/models/contry_state_model.dart' as cs_model;
import '../../../../../repositories/country_state_city_repo.dart';
import '../../../../shared/app_style.dart';

class DropDownContry extends StatefulWidget {
  const DropDownContry({super.key});

  @override
  State<DropDownContry> createState() => _DropDownContryState();
}

class _DropDownContryState extends State<DropDownContry> {
  final CountryStateCityRepo _countryStateCityRepo = CountryStateCityRepo();
  List<String> countries = [];
  List<String> states = [];
  List<String> cities = [];
  cs_model.CountryStateModel countryStateModel =
      cs_model.CountryStateModel(data: [], error: false, msg: "");
  CitiesModel citiesModel = CitiesModel(error: false, msg: '', data: []);

  String selectedCountry = 'Select Country';
  String selectedState = 'Select State';
  String selectedCity = 'Select City';
  bool isDataLoaded = false;

  String finalTextToBeDisplayed = '';
  getCountry() async {
    countryStateModel = await _countryStateCityRepo.getCountriesStates();
    countries.add('Select Country');
    states.add('Select State');
    cities.add('Select City');
    for (var element in countryStateModel.data) {
      countries.add(element.name);
    }
    isDataLoaded = true;
    setState(() {});
  }

  getState() async {
    for (var element in countryStateModel.data) {
      if (selectedCountry == element.name) {
        setState(() {
          resetState();
          resetCity();
        });
        for (var state in element.states) {
          states.add(state.name);
        }
      }
    }
  }

  getCities() async {
    isDataLoaded = false;
    citiesModel = await _countryStateCityRepo.getCities(
        country: selectedCountry, state: selectedState);
    for (var city in citiesModel.data) {
      cities.add(city);
    }
    isDataLoaded = true;
    setState(() {});
  }

  resetCity() {
    cities = [];
    cities.add('Select City');
    selectedCity = 'Select City';
    finalTextToBeDisplayed = '';
  }

  resetState() {
    states = [];
    states.add('Select State');
    selectedState = 'Select State';
    finalTextToBeDisplayed = '';
  }

  @override
  void initState() {
    getCountry();
    getState();
    getCities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isDataLoaded
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
        : Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Country",
                    style: appStyle(
                        14, FontWeight.normal, const Color(0xFF6C6C6C)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.black),
                      child: Column(
                        children: [
                          dropDownBuilderCountry(),
                          // Text(
                          //   finalTextToBeDisplayed,
                          //   style: const TextStyle(fontSize: 22, color: Colors.white),
                          // )
                        ],
                      )),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "state",
                    style: appStyle(
                        14, FontWeight.normal, const Color(0xFF6C6C6C)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.black),
                      child: dropDownBuilderState()),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "city",
                    style: appStyle(
                        14, FontWeight.normal, const Color(0xFF6C6C6C)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.black),
                      child: dropDownBuilderCity()),
                ],
              ),
            ],
          );
  }

  DropdownButton<String> dropDownBuilderCountry() {
    return DropdownButton<String>(
      isExpanded: true,
      value: selectedCountry,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      underline: Container(color: Colors.black),
      style: appStyle(
          17,
          FontWeight.normal,
          const Color(
            0xFFCDCDCD,
          )),
      dropdownColor: Colors.black,
      onChanged: (selectedValue) {
        // This is called when the user selects an item.
        setState(() {
          selectedCountry = selectedValue!;
        });
        getState();
      },
      items: countries
          .map<DropdownMenuItem<String>>(
              (String country) => DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  ))
          .toList(),
    );
  }

  DropdownButton<String> dropDownBuilderState() {
    return DropdownButton<String>(
      isExpanded: true,
      value: selectedState,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      underline: Container(color: Colors.black),
      style: appStyle(
          17,
          FontWeight.normal,
          const Color(
            0xFFCDCDCD,
          )),
      dropdownColor: Colors.black,
      onChanged: (selectedValue) {
        // This is called when the user selects an item.
        setState(() {
          selectedState = selectedValue!;
        });
        if (selectedState != 'Select State') {
          getCities();
        }
      },
      items: states
          .map<DropdownMenuItem<String>>(
              (String state) => DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  ))
          .toList(),
    );
  }

  DropdownButton<String> dropDownBuilderCity() {
    return DropdownButton<String>(
      isExpanded: true,
      value: selectedCity,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      underline: Container(color: Colors.black),
      style: appStyle(
          17,
          FontWeight.normal,
          const Color(
            0xFFCDCDCD,
          )),
      dropdownColor: Colors.black,
      onChanged: (selectedValue) {
        // This is called when the user selects an item.
        setState(() {
          selectedCity = selectedValue!;
        });
        if (selectedCity != 'Select City') {
          finalTextToBeDisplayed =
              "Country:$selectedCountry\n State:$selectedState \n City:$selectedCity";
        }
      },
      items: cities
          .map<DropdownMenuItem<String>>(
              (String city) => DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  ))
          .toList(),
    );
  }
}
