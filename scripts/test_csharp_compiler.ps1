$csharpSource = @"
using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Collections.Concurrent;

public class QueryResult
{
    public int Index { get; set; }
    public string QueryName { get; set; }
    public string Mode { get; set; }
    public int RowsReturned { get; set; }
    public long ElapsedMs { get; set; }
    public bool BlobIntegrity { get; set; }
    public bool Success { get; set; }
    public string ErrorMessage { get; set; }
}

public class QuerySpec
{
    public int Index { get; set; }
    public string QueryName { get; set; }
    public string Mode { get; set; }
    public string NameFilter { get; set; }
    public string GenderFilter { get; set; }
    public string CandidateId { get; set; }
}

public class ConcurrencyStressTester
{
    public static QueryResult ExecuteSingle(string connStr, QuerySpec spec)
    {
        var sw = Stopwatch.StartNew();
        var result = new QueryResult
        {
            Index = spec.Index,
            QueryName = spec.QueryName,
            Mode = spec.Mode,
            BlobIntegrity = true,
            Success = false
        };

        try
        {
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = @"SELECT 
                                CandidateId AS ID, 
                                FullName AS Name, 
                                City AS Location, 
                                Gender, 
                                CandidateId, 
                                FullName, 
                                JobTitle, 
                                Department, 
                                Email, 
                                Phone, 
                                City, 
                                Skills, 
                                ExperienceYears, 
                                Summary, 
                                PhotoPath, 
                                ResumePath, 
                                PhotoData 
                               FROM dbo.CandidateProfiles 
                               WHERE 1=1";

                if (spec.Mode == "Resume" && !string.IsNullOrEmpty(spec.CandidateId))
                {
                    sql += " AND CandidateId = @candId";
                }
                else
                {
                    if (!string.IsNullOrEmpty(spec.NameFilter))
                    {
                        sql += " AND FullName LIKE '%' + @fname + '%'";
                    }
                    if (!string.IsNullOrEmpty(spec.GenderFilter))
                    {
                        sql += " AND Gender = @gender";
                    }
                }
                sql += " ORDER BY CandidateId";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (spec.Mode == "Resume" && !string.IsNullOrEmpty(spec.CandidateId))
                    {
                        cmd.Parameters.AddWithValue("@candId", Convert.ToInt32(spec.CandidateId));
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(spec.NameFilter))
                        {
                            cmd.Parameters.AddWithValue("@fname", spec.NameFilter);
                        }
                        if (!string.IsNullOrEmpty(spec.GenderFilter))
                        {
                            cmd.Parameters.AddWithValue("@gender", spec.GenderFilter);
                        }
                    }

                    using (var da = new SqlDataAdapter(cmd))
                    {
                        var dt = new DataTable("Employee1");
                        da.Fill(dt);
                        result.RowsReturned = dt.Rows.Count;

                        foreach (DataRow row in dt.Rows)
                        {
                            var blob = row["PhotoData"] as byte[];
                            if (blob == null || blob.Length == 0)
                            {
                                result.BlobIntegrity = false;
                                break;
                            }
                        }
                    }
                }
            }
            result.Success = true;
        }
        catch (Exception ex)
        {
            result.Success = false;
            result.ErrorMessage = ex.Message;
        }
        finally
        {
            sw.Stop();
            result.ElapsedMs = sw.ElapsedMilliseconds;
        }

        return result;
    }

    public static QueryResult[] RunParallel(string connStr, QuerySpec[] specs, int maxDegreeOfParallelism)
    {
        var bag = new ConcurrentBag<QueryResult>();
        var options = new ParallelOptions { MaxDegreeOfParallelism = maxDegreeOfParallelism };

        Parallel.ForEach(specs, options, spec =>
        {
            var res = ExecuteSingle(connStr, spec);
            bag.Add(res);
        });

        var list = new System.Collections.Generic.List<QueryResult>(bag);
        list.Sort((a, b) => a.Index.CompareTo(b.Index));
        return list.ToArray();
    }
}
"@

Add-Type -TypeDefinition $csharpSource -ReferencedAssemblies "System.Data.dll", "System.Xml.dll", "System.Core.dll"
Write-Output "ConcurrencyStressTester compiled successfully!"
