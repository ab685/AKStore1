using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace AKStore.Repository
{
    public interface IBaseRepository<TEntity> : IDisposable
         where TEntity : class
    {
        IQueryable<TEntity> GetAll(Expression<Func<TEntity, bool>> filter = null);

        Task<TEntity> FirstOrDefaultAsync(Expression<Func<TEntity, bool>> filter);

        Task<TEntity> GetByIdAsync(int id);

        //Task CreateAsync(TEntity entity);

        //Task UpdateAsync(TEntity entity);

        Task DeleteAsync(int id);

        Task SaveChangesAsync();
        void SaveChanges();
        TEntity GetById(int id);

        void Create(TEntity entity);

        //void Update(TEntity entity);

        void Delete(int id);
    }
}
