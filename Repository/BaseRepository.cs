using AutoMapper.Configuration;
using AKStore.AppContext;
using System;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace AKStore.Repository
{
    public class BaseRepository<TEntity> : IBaseRepository<TEntity>
         where TEntity : class
    {
        protected AKStoreContext db;
        protected DbSet<TEntity> entities;

        public BaseRepository()
        {
            this.db = new AKStoreContext();
            entities = db.Set<TEntity>();
        }
        public IQueryable<TEntity> GetAll(Expression<Func<TEntity, bool>> filter = null)
        {
            IQueryable<TEntity> query = entities;
            if (filter != null)
            {
                query = query.Where(filter);
            }

            return query;
        }

        public async Task<TEntity> GetByIdAsync(int id)
        {
            return await entities.FindAsync(id);
        }

        //public async Task CreateAsync(TEntity entity)
        //{
        //    await entities.Add(entity);
        //    await db.SaveChangesAsync();
        //}

        //public async Task UpdateAsync(TEntity entity)
        //{
        //    entities.Update(entity);
        //    await db.SaveChangesAsync();
        //}

        public async Task DeleteAsync(int id)
        {
            var entity = await entities.FindAsync(id);
            entities.Remove(entity);
            await db.SaveChangesAsync();
        }
        public void Delete(int id)
        {
            var entity = entities.Find(id);
            entities.Remove(entity);
            db.SaveChanges();
        }

        public async Task<TEntity> FirstOrDefaultAsync(Expression<Func<TEntity, bool>> filter)
        {
            return await entities.FirstOrDefaultAsync(filter);
        }

        public async Task SaveChangesAsync() => await db.SaveChangesAsync(); 
        public void SaveChanges() =>  db.SaveChanges();


        public TEntity GetById(int id)
        {
            return entities.Find(id);
        }

        public void Create(TEntity entity)
        {
            entities.Add(entity);
            db.SaveChanges();
        }

        //public void Update(TEntity entity)
        //{
        //    entities.Update(entity);
        //    db.SaveChanges();
        //}
        #region IDisposable Support
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                // dispose resources when needed
            }
        }
        #endregion
    }
}
