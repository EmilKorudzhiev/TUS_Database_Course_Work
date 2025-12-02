package com.example.coursework.service;

import com.example.coursework.model.dto.LatLng;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.ArrayList;
import java.util.List;

@Service
public class DirectionsService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${google.maps.api-key}")
    private String apiKey;

    public DirectionsService() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }

    /**
     * origin и destination са във формат "lat,lng", напр. "42.6977,23.3219"
     */
    public List<LatLng> getRoute(String origin, String destination) {
        String url = UriComponentsBuilder
                .fromHttpUrl("https://maps.googleapis.com/maps/api/directions/json")
                .queryParam("origin", origin)
                .queryParam("destination", destination)
                .queryParam("mode", "driving")
                .queryParam("key", apiKey)
                .build()
                .toUriString();

        String json = restTemplate.getForObject(url, String.class);
        if (json == null) {
            return List.of();
        }

        try {
            JsonNode root = objectMapper.readTree(json);

            JsonNode routes = root.get("routes");
            if (routes == null || !routes.isArray() || routes.isEmpty()) {
                return List.of();
            }

            JsonNode firstRoute = routes.get(0);
            JsonNode overviewPolyline = firstRoute.get("overview_polyline");
            if (overviewPolyline == null || overviewPolyline.get("points") == null) {
                return List.of();
            }

            String encoded = overviewPolyline.get("points").asText();
            return decodePolyline(encoded);

        } catch (Exception e) {
            e.printStackTrace();
            return List.of();
        }
    }

    /**
     * Стандартен polyline декодер на Google.
     * Връща списък LatLng точки по маршрута.
     */
    private List<LatLng> decodePolyline(String encoded) {

        List<LatLng> poly = new ArrayList<>();
        int index = 0, len = encoded.length();
        int lat = 0, lng = 0;

        while (index < len) {
            int b, shift = 0, result = 0;
            do {
                b = encoded.charAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
            lat += dlat;

            shift = 0;
            result = 0;
            do {
                b = encoded.charAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
            lng += dlng;

            double finalLat = lat / 1E5;
            double finalLng = lng / 1E5;
            poly.add(new LatLng(finalLat, finalLng));
        }

        return poly;
    }
}
