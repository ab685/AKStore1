﻿using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
namespace AKStore.Services
{
    public class ProductPurchaseService : BaseService, IProductPurchaseService
    {
        private readonly IProductPurchaseRepository _ProductPurchaseRepository;
        public ProductPurchaseService() : base()
        {
            _ProductPurchaseRepository = new ProductPurchaseRepository();
        }

        public List<ProductPurchaseModel> GetProductPurchase(int? ProductId)
        {
            return _ProductPurchaseRepository.GetProductPurchase(ProductId);
        }
    }
}
