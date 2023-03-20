# kc-carseat [![Release](https://img.shields.io/badge/Release-V%201.0-blue)](https://github.com/clementinise/kc-carseat/releases/latest)

**Allow players to enter a vehicle through any door - [kc-carseat on cfx.re forum](https://forum.cfx.re/t/standalone-kc-carseat/5051810)** 

### This resource uses [FiveM-checker](https://forum.cfx.re/t/release-fivem-resource-update-checker-fivem-checker-v1-0-free/4802991), created to easily keep track of whether a resource needs to be updated!

## FEATURES

* Choose which seat to enter when approaching a vehicle
* Pressing the specified key twice allows players to go to the seat on the other side from the current entered door
* Compatible with both keyboard and controller inputs
* Update Checker and changelog if a new update is found directly in the console on resource start, except if [`fivem-checker`](https://forum.cfx.re/t/release-fivem-resource-update-checker-fivem-checker-v1-0-free/4802991) is installed and running on your server
* Run at 0.00ms (0.00%) on idle and 0.01ms when inside a vehicle (Max reached is 0.02ms)
* Highly optimized script to ensure minimal performance impact
* Proper locale system with French and English language already included
* If you run into any issue with this resource, just set 'Config.Debug' to true, it will print some debug logs in the client console. You can then send them on this post :+1: 

## kc-carseat is higly configurable:
* **Config.FacingOnly** Choose whether the seat selection only works when the player is facing the vehicle
* **Config.Distance** Set the maximum distance from the vehicle for seat selection to work
* **Config.WaitForDoubleInput** Set the time window for double input (in milliseconds) for switching seats
* **Config.Language** Set the language variable that will be used for the locale system. For now, kc-carseat has translations in French and English (fr or en), but you can easily create your own translation!
* **Config.UpdateChecker** Set to false if you don't want to check for kc-carseat updates on start
* **Config.ChangeLog** Set to false if you don't want to display the changelog if a new version is found

**KNOWN BUG :** 
* None

**Preview:** [Coming Soon]()

## Installation

Download the [latest release](https://github.com/clementinise/kc-unicorn/releases/latest).

Drag the folder into your `<server-data>/resources/` folder 
Add this in your `server.cfg`:
```
start kc-carseat
```
