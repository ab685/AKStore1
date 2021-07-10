using AKStore.Entity;
using AKStore.Extension;
using AKStore.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Repository
{
    public class RetailerDetailsRepository : BaseRepository<RetailerDetails>, IRetailerDetailsRepository
    {
        public IEnumerable<RetailerDetailsModel> GetRetailerDetails()
        {
            var DistributorId = Convert.ToInt32(HttpContext.Current.Session["DistributorId"]);
            var p = new DynamicParameters();
            p.Add("@DistributorId", DistributorId);
            var retailerDetailsModels = CommonOperations.Query<RetailerDetailsModel>("GetRetailerDetails", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return retailerDetailsModels;

        }


        public RetailerDetailsModel GetRetailerDetailsById(int id)
        {
            var DistributorId = Convert.ToInt32(HttpContext.Current.Session["DistributorId"]);
            var p = new DynamicParameters();
            p.Add("@Id", id);
            p.Add("@DistributorId", DistributorId);
            var retailerDetailsModel = CommonOperations.Query<RetailerDetailsModel>("GetRetailerDetailsById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return retailerDetailsModel;
        }

        public int GetRetailerDetailsByRetailerId(int id)
        {
            var count = db.RetailerDetails.Where(x => x.RetailerId == id).Count();
            return count;
        }


    }
}
