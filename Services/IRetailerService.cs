using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Services
{
    public interface IRetailerService
    {
        IEnumerable<RetailerModel> GetRetailers();
        void UpsertRetailerDetails(RetailerDetailsModel retailerDetailsModel);
       
    }
}
