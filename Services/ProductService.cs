using AutoMapper;
using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
namespace AKStore.Services
{
    public class ProductService : BaseService, IProductService
    {
        private readonly IProductRepository _productRepository;
        public ProductService() : base()
        {
            _productRepository = new ProductRepository();
        }

        public IEnumerable<ProductModel> GetProduct(int distributorId)
        {
            var productMasters = _productRepository.GetProducts(distributorId);
            return AutoMapper.Mapper.Map<IEnumerable<ProductModel>>(productMasters);
        }
        public ProductModel GetProductById(int id)
        {
            var product = _productRepository.GetProductById(id);
            return AutoMapper.Mapper.Map<ProductModel>(product);
        }

        public Tuple<bool, string> UpsertProduct(ProductModel productModel)
        {
            
            var productMaster = AutoMapper.Mapper.Map<ProductMaster>(productModel);
            
            return _productRepository.UpsertProduct(productMaster);
        }
        public Tuple<bool, string> DeleteProduct(int productId)
        {
            return _productRepository.DeleteProduct(productId);
        }
        public void AddPurchasedProduct(int productId, int quantity, decimal price)
        {
            _productRepository.AddPurchasedProduct(productId, quantity, price);
        }
    }
}
