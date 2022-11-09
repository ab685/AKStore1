using AKStore.Entity;
using AKStore.Extension;
using AKStore.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

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
        public void ChangeProductPurchaseData(int id, int productId, int quantity, decimal price)
        {
            var p = new DynamicParameters();
            p.Add("@Id", id);
            p.Add("@ProductId", productId);
            p.Add("@PurchasePrice", price);
            p.Add("@Quantity", quantity);
            p.Add("@UserId", Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]));
            CommonOperations.Query<ProductPurchaseModel>("dbo.ChangeProductPurchaseData", p, commandType: System.Data.CommandType.StoredProcedure).ToList();

        }
        public void DeleteProductPurchase(int id)
        {
            var p = new DynamicParameters();
            p.Add("@Id", id);
            p.Add("@UserId", Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]));
            CommonOperations.Query<ProductPurchaseModel>("dbo.DeleteProductPurchase", p, commandType: System.Data.CommandType.StoredProcedure).ToList();

        }
    }
}

