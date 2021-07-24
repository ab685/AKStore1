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
            if (productMaster.Id == 0)
            {
                productMaster.InsertedDate = DateTime.Now;
                productMaster.InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                db.ProductMaster.Add(productMaster);
                db.SaveChanges();
                message = "Product added successfully";
                success = true;
            }
            else
            {
                var product = db.ProductMaster.Find(productMaster.Id);
                if (product != null)
                {
                    product.Id = productMaster.Id;
                    product.Name = productMaster.Name;
                    product.Description = productMaster.Description;
                    product.Price = productMaster.Price;
                    product.Quantity = productMaster.Quantity;
                    if (!string.IsNullOrEmpty(productMaster.FilePath))
                    {
                        product.FilePath = productMaster.FilePath;
                    }
                    product.UpdatedDate = DateTime.Now;
                    product.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                    product.DistributorId = productMaster.DistributorId;
                    product.CompanyId = productMaster.CompanyId;
                    product.CategoryId = productMaster.CategoryId;
                    // db.ProductMaster.Update(product);
                    db.SaveChanges();
                    message = "Product updated successfully";
                    success = true;
                }
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
            if (msg==null)
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
    }
}
