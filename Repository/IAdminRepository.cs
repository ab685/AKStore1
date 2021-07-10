using AKStore.Entity;
using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface IAdminRepository : IBaseRepository<Admin>
    {
        IEnumerable<AdminModel> GetAdmins();
        AdminModel GetAdminById(int id);

    }


}
