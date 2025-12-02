package com.example.coursework.util;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

public class LocationUtil {
    private static final double MIN_LAT = 42.63;
    private static final double MAX_LAT = 42.73;
    private static final double MIN_LNG = 23.25;
    private static final double MAX_LNG = 23.42;

    public static String randomLocationInSofia() {
        double lat = ThreadLocalRandom.current().nextDouble(MIN_LAT, MAX_LAT);
        double lng = ThreadLocalRandom.current().nextDouble(MIN_LNG, MAX_LNG);
        return lat + "," + lng;
    }

    private static final double EARTH_RADIUS_KM = 6371.0;

    public static double distanceKm(String loc1, String loc2) {
        double[] p1 = parseLocation(loc1);
        double[] p2 = parseLocation(loc2);

        double lat1 = p1[0];
        double lon1 = p1[1];
        double lat2 = p2[0];
        double lon2 = p2[1];

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double rLat1 = Math.toRadians(lat1);
        double rLat2 = Math.toRadians(lat2);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(rLat1) * Math.cos(rLat2)
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c;
    }

    public static List<String> generatePath(String startLoc, String endLoc, int steps) {
        double[] p1 = parseLocation(startLoc);
        double[] p2 = parseLocation(endLoc);

        double lat1 = p1[0];
        double lon1 = p1[1];
        double lat2 = p2[0];
        double lon2 = p2[1];

        List<String> path = new ArrayList<>();

        // включваме стартовата точка
        path.add(lat1 + "," + lon1);

        for (int i = 1; i < steps; i++) {
            double t = (double) i / steps; // от 0 до 1
            double lat = lat1 + t * (lat2 - lat1);
            double lon = lon1 + t * (lon2 - lon1);
            path.add(lat + "," + lon);
        }

        // крайна точка (за всеки случай)
        path.add(lat2 + "," + lon2);

        return path;
    }

    private static double[] parseLocation(String loc) {
        if (loc == null) {
            throw new IllegalArgumentException("Location is null");
        }
        String[] parts = loc.split(",");
        if (parts.length != 2) {
            throw new IllegalArgumentException("Invalid location format: " + loc);
        }
        double lat = Double.parseDouble(parts[0].trim());
        double lon = Double.parseDouble(parts[1].trim());
        return new double[]{lat, lon};
    }
}
