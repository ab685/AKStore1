using AKStore.Entity;
using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface IProductPurchaseRepository : IBaseRepository<ProductPurchase>
    {
        List<ProductPurchaseModel> GetProductPurchase(int? ProductId);
        void ChangeProductPurchaseData(int id, int productId, int quantity, decimal price);
    }
}
