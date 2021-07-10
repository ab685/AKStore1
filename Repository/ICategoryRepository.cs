using AKStore.Entity;
using System;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface ICategoryRepository : IBaseRepository<Category>
    {
        IEnumerable<Category> GetCategoryByDistributorId(int distributorId);
        Category GetCategoryById(int id);
        Tuple<bool, string> UpsertCategory(Category category);
    } 
}