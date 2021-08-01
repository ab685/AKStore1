using AKStore.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AKStore.Repository
{
    public interface IProductRepository : IBaseRepository<ProductMaster>
    {
        Tuple<bool, string> UpsertProduct(ProductMaster productMaster);
        Tuple<bool, string> DeleteProduct(int productId);
        IEnumerable<ProductMaster> GetProducts(int distributorId);
        ProductMaster GetProductById(int id);
        void ChangeProductData(int productId, decimal quantity, decimal price);
    }
}
