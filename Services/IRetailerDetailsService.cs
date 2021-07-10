using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Services
{
    public interface IRetailerDetailsService
    {
        IEnumerable<RetailerDetailsModel> GetRetailerDetails();
        RetailerDetailsModel GetRetailerDetailsById(int id);
        void UpsertRetailerDetails(RetailerDetailsModel retailerDetailsModel);
        int GetRetailerDetailsByRetailerId(int id);
        void DeleteRetailerDetails(int id, bool isActive);
    }
}
