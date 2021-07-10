using AKStore.Models;
using System;
using System.Collections.Generic;

namespace AKStore.Services
{
    public interface ICompanyService
    {
        IEnumerable<CompanyModel> GetCompanyByDistributorId(int distributorId);
        CompanyModel GetCompanyById(int id);
        Tuple<bool, string> UpsertCompany(CompanyModel company);
    }

}