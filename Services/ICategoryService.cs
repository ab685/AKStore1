using AKStore.Models;
using System;
using System.Collections.Generic;

namespace AKStore.Services
{
    public interface ICategoryService
    {
        IEnumerable<CategoryModel> GetCategoryByDistributorId(int distributorId);
        CategoryModel GetCategoryById(int id);
        Tuple<bool, string> UpsertCategory(CategoryModel category);
        Tuple<bool, string> DeleteCategory(int id);
    }

}