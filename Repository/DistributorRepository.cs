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
    public class DistributorRepository : BaseRepository<Distributor>, IDistributorRepository
    {
        public IEnumerable<DistributorModel> GetDistributors()
        {
            var AdminId = Convert.ToInt32(HttpContext.Current.Session["AdminId"]);
            var p = new DynamicParameters();
            p.Add("@AdminId", AdminId);
            var distributorModels = CommonOperations.Query<DistributorModel>("GetDistributors", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return distributorModels;
        }
        public DistributorModel GetDistributorById(int id)
        {
            var p = new DynamicParameters();
            p.Add("@Id", id);
            var distributorModel = CommonOperations.Query<DistributorModel>("GetDistributorById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return distributorModel;
        }
        public Distributor FirstDistributor()
        {
            return GetAll().FirstOrDefault();
        }


    }
}
