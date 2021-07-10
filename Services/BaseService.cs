using AutoMapper;
using System;

namespace AKStore.Services
{
    public class BaseService : IBaseService
    {
      
        public BaseService()
        {
            
        }

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
