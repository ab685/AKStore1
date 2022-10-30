using AKStore.Entity;
using AKStore.Extension;
using AKStore.Models;
using Dapper;
using System.Collections.Generic;
using System.Linq;

namespace AKStore.Repository
{
    public class ProductPurchaseRepository : BaseRepository<ProductPurchase>, IProductPurchaseRepository
    {
        public List<ProductPurchaseModel> GetProductPurchase(int? ProductId)
        {
            var p = new DynamicParameters();
            p.Add("@ProductId", ProductId);
            var productPurchases = CommonOperations.Query<ProductPurchaseModel>("dbo.GetProductPurchase", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return productPurchases;
        }
    }
}
