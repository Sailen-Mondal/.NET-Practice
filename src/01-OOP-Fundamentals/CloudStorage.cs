namespace Assignment;

// Question 9: Interface-based programming.
public interface ICloudStorageProvider
{
    void UploadFile(string path);
    void DownloadFile(string fileId);
    void DeleteFile(string fileId);
}

public class S3Storage : ICloudStorageProvider
{
    public void UploadFile(string path)
    {
        Console.WriteLine("S3 uploaded " + path);
    }

    public void DownloadFile(string fileId)
    {
        Console.WriteLine("S3 downloaded " + fileId);
    }

    public void DeleteFile(string fileId)
    {
        Console.WriteLine("S3 deleted " + fileId);
    }
}

public class AzureStorage : ICloudStorageProvider
{
    public void UploadFile(string path)
    {
        Console.WriteLine("Azure uploaded " + path);
    }

    public void DownloadFile(string fileId)
    {
        Console.WriteLine("Azure downloaded " + fileId);
    }

    public void DeleteFile(string fileId)
    {
        Console.WriteLine("Azure deleted " + fileId);
    }
}
