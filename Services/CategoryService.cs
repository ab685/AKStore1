using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Services
{
    public class CategoryService : BaseService, ICategoryService
    {
        private readonly ICategoryRepository _categoryRepository;
        public CategoryService()
        {
            _categoryRepository = new CategoryRepository();
        }
        public IEnumerable<CategoryModel> GetCategoryByDistributorId(int distributorId)
        {
            var categories = _categoryRepository.GetCategoryByDistributorId(distributorId);
            return AutoMapper.Mapper.Map<IEnumerable<CategoryModel>>(categories);
        }

        public CategoryModel GetCategoryById(int id)
        {
            var category = _categoryRepository.GetCategoryById(id);
            return AutoMapper.Mapper.Map<CategoryModel>(category);
        }

        public Tuple<bool, string> UpsertCategory(CategoryModel category)
        {
            var category1 = AutoMapper.Mapper.Map<Category>(category);
            return _categoryRepository.UpsertCategory(category1);
        }
        public Tuple<bool, string> DeleteCategory(int id)
        {
            return _categoryRepository.DeleteCategory(id);
        }
       
    }

}