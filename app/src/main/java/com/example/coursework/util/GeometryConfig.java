package com.example.coursework.util;

import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.locationtech.jts.geom.GeometryFactory;
@Configuration
public class GeometryConfig {

    @Bean
    public GeometryFactory geometryFactory() {
        // SRID 4326 = WGS84 (lat/lng)
        return new GeometryFactory(new PrecisionModel(), 4326);
    }
}
