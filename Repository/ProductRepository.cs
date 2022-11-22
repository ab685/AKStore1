using AKStore.Entity;
using AKStore.Extension;
using Dapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
namespace AKStore.Repository
{
    public class ProductRepository : BaseRepository<ProductMaster>, IProductRepository
    {
        public Tuple<bool, string> UpsertProduct(ProductMaster productMaster)
        {
            DistributorRepository distributorRepository = new DistributorRepository();
            productMaster.DistributorId = distributorRepository.GetAll().FirstOrDefault().Id;
            string message = string.Empty;
            bool success = false;
            var p = new DynamicParameters();
            p.Add("@Id", productMaster.Id);
            p.Add("@CategoryId", productMaster.CategoryId);
            p.Add("@CompanyId", productMaster.CompanyId);
            p.Add("@DistributorId", productMaster.DistributorId);
            p.Add("@Name", productMaster.Name);
            p.Add("@Description", productMaster.Description);
            p.Add("@SellPrice", productMaster.SellPrice);
            p.Add("@DiscountInNumbers", productMaster.DiscountInNumbers);
            p.Add("@MinQuantityForDiscount", productMaster.MinQuantityForDiscount);
            p.Add("@DiscountType", productMaster.DiscountType);
         
            if (!string.IsNullOrEmpty(productMaster.FilePath))
            {
                p.Add("@FilePath", productMaster.FilePath);
            }

            p.Add("@InsertedByUserId", Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]));
            p.Add("@UpdatedByUserId", Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]));
            p.Add("@HasDiscount", productMaster.HasDiscount);
            p.Add("@OprType", productMaster.Id == 0 ? 1 : 3);
            CommonOperations.Query<int>("ProductMasterSIDU", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            if (productMaster.Id == 0)
            {
                message = "Product added successfully";
                success = true;
            }
            else
            {
                message = "Product updated successfully";
                success = true;
            }
            return new Tuple<bool, string>(success, message);
        }
        public Tuple<bool, string> DeleteProduct(int productId)
        {
            var message = string.Empty;
            var success = false;
            var p = new DynamicParameters();
            p.Add("@Id", productId);
            p.Add("@TableName", "product");
            var msg = CommonOperations.Query<string>("DeleteById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            if (msg == null)
            {
                message = "Product deleted successfully.";
                success = true;
            }
            else
            {
                message = "Product not found.";
                success = false;
            }
            return new Tuple<bool, string>(success, message);
        }
        public IEnumerable<ProductMaster> GetProducts(int distributorId)
        {
            var p = new DynamicParameters();
            p.Add("@distributorId", distributorId);
            var products = CommonOperations.Query<ProductMaster>("GetProducts", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return products;
        }
        public ProductMaster GetProductById(int id)
        {
            var p = new DynamicParameters();
            p.Add("@Id", id);
            var productMaster = CommonOperations.Query<ProductMaster>("GetProductById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return productMaster;
        }
        public void AddPurchasedProduct(int productId, int quantity, decimal price)
        {
            var p = new DynamicParameters();
            p.Add("@ProductId", productId);
            p.Add("@Quantity", quantity);
            p.Add("@PurchasePrice", price);
            p.Add("@UserId", Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]));
            var msg = CommonOperations.Query<string>("AddPurchasedProduct", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
        }
    }
}
