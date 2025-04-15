package com.schedulizer;

import java.util.Map;

public class AvailabilityRequest {
    private String email;
    private String weekStart;
    private Map<String, String> availability;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getWeekStart() { return weekStart; }
    public void setWeekStart(String weekStart) { this.weekStart = weekStart; }

    public Map<String, String> getAvailability() { return availability; }
    public void setAvailability(Map<String, String> availability) { this.availability = availability; }
}
