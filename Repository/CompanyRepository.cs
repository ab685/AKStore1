using AKStore.Entity;
using AKStore.Extension;
using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace AKStore.Repository
{
    public class CompanyRepository : BaseRepository<Company>, ICompanyRepository
    {
        public IEnumerable<Company> GetCompanyByDistributorId(int distributorId)
        {
            var p = new DynamicParameters();
            p.Add("@distributorId", distributorId);
            var companies = CommonOperations.Query<Company>("GetCompany", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return companies;
        }
        public Company GetCompanyById(int id)
        {
            var p = new DynamicParameters();
            p.Add("@id", id);
            var companies = CommonOperations.Query<Company>("GetCompanyById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return companies;
        }
        public Tuple<bool, string> UpsertCompany(Company company)
        {
            var DistributorId = Convert.ToInt32(HttpContext.Current.Session["DistributorId"]);
            company.DistributorId = DistributorId;
            string message = string.Empty;
            bool success = false;
            if (company.Id == 0)
            {


                message = "Company added successfully";
                success = true;

                company.InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                company.InsertedDate = DateTime.Now;

            }
            else
            {
                company.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                company.UpdatedDate = DateTime.Now;
                message = "Company updated successfully";
                success = true;
            }
            var p = new DynamicParameters();
            p.Add("@Id", company.Id);
            p.Add("@DistributorId", company.DistributorId);
            p.Add("@CategoryId", company.CategoryId);
            p.Add("@Name", company.Name);
            p.Add("@Description", company.Description);
            p.Add("@FilePath", company.FilePath);
            p.Add("@InsertedDate", company.InsertedDate);
            p.Add("@UpdatedDate", company.UpdatedDate);
            p.Add("@InsertedByUserId", company.InsertedByUserId);
            p.Add("@UpdatedByUserId", company.UpdatedByUserId);
            var msg = CommonOperations.Query<int>("UpsertCompany", p, commandType: CommandType.StoredProcedure).FirstOrDefault();
            if (msg == 0)
            {
                message = "Some thing went wrong";
                success = false;
            }


            return new Tuple<bool, string>(success, message);
        }
    }
}