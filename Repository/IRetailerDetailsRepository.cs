using AKStore.Entity;
using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface IRetailerDetailsRepository : IBaseRepository<RetailerDetails>
    {
        IEnumerable<RetailerDetailsModel> GetRetailerDetails();
        RetailerDetailsModel GetRetailerDetailsById(int id);
        int GetRetailerDetailsByRetailerId(int id);
    }
        


}
