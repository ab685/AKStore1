using AKStore.Entity;
using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface IDistributorRepository : IBaseRepository<Distributor>
    {
        IEnumerable<DistributorModel> GetDistributors();
        DistributorModel GetDistributorById(int id);
    }
        


}
