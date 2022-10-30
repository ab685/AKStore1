using System.Collections.Generic;
using AKStore.Models;
namespace AKStore.Services
{
    public interface IProductPurchaseService
    {
        List<ProductPurchaseModel> GetProductPurchase(int? ProductId);
    }
}
