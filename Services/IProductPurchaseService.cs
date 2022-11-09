using System.Collections.Generic;
using AKStore.Models;
namespace AKStore.Services
{
    public interface IProductPurchaseService
    {
        List<ProductPurchaseModel> GetProductPurchase(int? ProductId);
        void ChangeProductPurchaseData(int id, int productId, int quantity, decimal price);
        void DeleteProductPurchase(int id);
    }
}
