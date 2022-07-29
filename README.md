### Hi there 👋

This project will try to develop navigation Augmented Reality map for the University of Leeds. 
Two main libraries have used the app to deal with the AR problem. The first one is the ARCL library which Dent creates. Another one is the ARCoreLocation library. These two libraries can be downloaded from Cocoapods.

After trying to use these two libraries, it is beneficial for people to deal with the problem of applying the AR object by using the geographical coordinates(latitudes, longitudes and altitudes). However, there is a problem that the AR route will keep jumping around. All I know so far is that it is affected by the GPS signal. 

Also, the route can create a slope for uphill or downhill roads. It is because Mapkit does not include any altitudes data. However, it can get the altitude data from the current location. Therefore, it is necessary to turn the " public var ignoreAltitude = true" and keep tracking the latitudes, longitudes and altitudes.
