using AKStore.Entity;
using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface IProductPurchaseRepository : IBaseRepository<ProductPurchase>
    {
        List<ProductPurchaseModel> GetProductPurchase(int? ProductId);
    }
}
