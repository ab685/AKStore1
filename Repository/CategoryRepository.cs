﻿using AKStore.Entity;
using AKStore.Extension;
using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace AKStore.Repository
{
    public class CategoryRepository: BaseRepository<Category>, ICategoryRepository
    {
        public IEnumerable<Category> GetCategoryByDistributorId(int distributorId)
        {
            var p = new DynamicParameters();
            p.Add("@distributorId", distributorId);
            var categories = CommonOperations.Query<Category>("GetCategory", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return categories;
        }
        public Category GetCategoryById(int id)
        {
            var p = new DynamicParameters();
            p.Add("@id", id);
            var categories = CommonOperations.Query<Category>("GetCategoryById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return categories;
        }

        public Tuple<bool, string> UpsertCategory(Category category)
        {
            var DistributorId = Convert.ToInt32(HttpContext.Current.Session["DistributorId"]);
            category.DistributorId = DistributorId;
            string message = string.Empty;
            bool success = false;
            if (category.Id == 0)
            {


                message = "Category added successfully";
                success = true;

                category.InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                category.InsertedDate = DateTime.Now;
            }
            else
            {
                category.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                category.UpdatedDate = DateTime.Now;
                message = "Category updated successfully";
                success = true;
            }
            var p = new DynamicParameters();
            p.Add("@Id", category.Id);
            p.Add("@DistributorId", category.DistributorId);
            p.Add("@Name", category.Name);
            p.Add("@Description", category.Description);
            p.Add("@FilePath", category.FilePath);
            p.Add("@InsertedDate", category.InsertedDate);
            p.Add("@UpdatedDate", category.UpdatedDate);
            p.Add("@InsertedByUserId", category.InsertedByUserId);
            p.Add("@UpdatedByUserId", category.UpdatedByUserId);
            var msg = CommonOperations.Query<int>("UpsertCategory", p, commandType: CommandType.StoredProcedure).FirstOrDefault();
            if (msg ==0)
            {
                message = "Some thing went wrong";
                success = false;
            }


            return new Tuple<bool, string>(success, message);
        }

        
    }
}