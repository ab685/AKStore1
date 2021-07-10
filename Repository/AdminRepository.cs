using AKStore.Entity;
using AKStore.Extension;
using AKStore.Models;
using Dapper;
using System.Collections.Generic;
using System.Linq;

namespace AKStore.Repository
{
    public class AdminRepository : BaseRepository<Admin>, IAdminRepository
    {
        public IEnumerable<AdminModel> GetAdmins()
        {
            var adminModels = CommonOperations.Query<AdminModel>("GetAdmins", new object { }, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return adminModels;
        }
        public AdminModel GetAdminById(int id)
        {
            var p = new DynamicParameters();
            p.Add("@Id", id);
            var adminModel = CommonOperations.Query<AdminModel>("GetAdminById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return adminModel;

        }


    }
}
