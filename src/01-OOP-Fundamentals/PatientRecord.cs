namespace Assignment;

// Question 2: Encapsulation and data hiding.
public class PatientRecord
{
    private int _heartRate;
    private double _temperature;

    public PatientRecord(string patientName, string medicalHistory)
    {
        PatientName = patientName;
        MedicalHistory = medicalHistory;
    }

    public string PatientName { get; set; }
    public string MedicalHistory { get; private set; }
    public bool BillingPaid { get; private set; }

    public int GetHeartRate()
    {
        return _heartRate;
    }

    public double GetTemperature()
    {
        return _temperature;
    }

    public void UpdateVitalSigns(int heartRate, double temperature)
    {
        if (heartRate > 0 && temperature > 0)
        {
            _heartRate = heartRate;
            _temperature = temperature;
        }
    }

    public void UpdateMedicalHistory(string medicalHistory)
    {
        MedicalHistory = medicalHistory;
    }

    public void MarkBillAsPaid()
    {
        BillingPaid = true;
    }
}
