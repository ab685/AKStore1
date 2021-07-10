using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AKStore.Models;

namespace AKStore.Services
{
    public interface IProductService
    {
        IEnumerable<ProductModel> GetProduct(int distributorId);

        Tuple<bool, string> UpsertProduct(ProductModel productModel);
        Tuple<bool, string> DeleteProduct(int productId);
        ProductModel GetProductById(int id);
    }
}
