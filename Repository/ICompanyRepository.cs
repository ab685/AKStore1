using AKStore.Entity;
using System;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface ICompanyRepository : IBaseRepository<Company>
    {
        Company GetCompanyById(int id);
        Tuple<bool, string> UpsertCompany(Company company);
        IEnumerable<Company> GetCompanyByDistributorId(int distributorId);
        Tuple<bool, string> DeleteCompany(int id);
    }
}