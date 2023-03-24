### Hi there 👋
The (JasperHO1228 file) project will try to develop a navigation Augmented Reality map for the University of Leeds. 
Two main libraries have used in this app for dealing with the AR problem. The first one is the ARCL library which Dent creates. Another one is the ARCoreLocation library. These two libraries can be downloaded from Cocoapods.

After trying to use these two libraries, it is beneficial for people to deal with the problem of applying the AR object by using the geographical coordinates(latitudes, longitudes and altitudes). However, there is a problem that the AR route will keep jumping around. All I know so far is that it is affected by the GPS signal and the route data is updating too fast. I believed that Kalma filter algorithm should be used, in order to solve the instability of AR route.

Also, the route cannot create a slope for uphill or downhill roads. It is because Mapkit does not include any altitudes data. However, it can get the altitude data from the current location. Therefore, it is necessary to turn the " public var ignoreAltitude = true" and keep tracking the latitudes, longitudes and altitudes.

Noted: customroute.swift file still need to be investigated. This file is planning to create a function that after plotting the AR route manully, than save 
the AR scene. If the user want to use the route again, just tapping the reload button to load the AR route that have been plotted.
This file has been used two key tools, SCNPATH(downloaded from cocoapods) and ARWorldMap.

The result has been posted on this link: https://www.youtube.com/watch?v=UBDnyYBA4eU&t=220s&ab_channel=hojasper
