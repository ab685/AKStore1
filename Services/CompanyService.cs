using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;

namespace AKStore.Services
{
    public class CompanyService : BaseService, ICompanyService
    {
        private readonly ICompanyRepository _companyRepository;
        public CompanyService()
        {
            _companyRepository = new CompanyRepository();
        }
        public IEnumerable<CompanyModel> GetCompanyByDistributorId(int distributorId)
        {
            var companies = _companyRepository.GetCompanyByDistributorId(distributorId);
            return AutoMapper.Mapper.Map<IEnumerable<CompanyModel>>(companies);
        }

        public CompanyModel GetCompanyById(int id)
        {
            var company = _companyRepository.GetCompanyById(id);
            return AutoMapper.Mapper.Map<CompanyModel>(company);
        }

        public Tuple<bool, string> UpsertCompany(CompanyModel company)
        {
            var Company1 = AutoMapper.Mapper.Map<Company>(company);
            return _companyRepository.UpsertCompany(Company1);
        }
    }

}