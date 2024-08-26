import { ref, Ref } from 'vue'
import { defineStore } from 'pinia'
import { useApolloClient } from '@vue/apollo-composable'
import { ProductType, QueryVariablesType, CreateProductVariablesType, UpdateProductVariablesType } from '@/_types/types'
import productsGql from '@/graphql/products/products.graphql'
import createProductGql from '@/graphql/products/createProduct.graphql'
import updateProductGql from '@/graphql/products/updateProduct.graphql'

export const useProductStore = defineStore('product', () => {
  const client = useApolloClient().client

  const loading = ref(false)

  const products = ref<ProductType[]>([]) as Ref<ProductType[]>

  // Queries
  const fetchProducts = async (variables: QueryVariablesType): Promise<boolean> => {
    try {
      loading.value = true
      const { data, errors } = await client.query({
        query: productsGql,
        variables
      })

      if (errors) {
        console.error('Query Error:', errors)
        
        return false
      }

      products.value = data.products as ProductType[]
  
      return true
    } catch (error) {
      console.error('Catch Query Error:', error)

      return false
    } finally {
      loading.value = false
    }
  }

  // Mutations
  const createProduct = async (variables: CreateProductVariablesType): Promise<boolean> => {
    try {
      loading.value = true

      const { errors } = await client.mutate({
        mutation: createProductGql,
        variables
      })

      if (errors) {
        console.error('Mutation Error:', errors)

        return false
      }

      return true
    } catch (error) {
      console.error('Catch Mutation Error:', error)

      return false
    } finally {
      loading.value = false
    }
  }

  const updateProduct = async (variables: UpdateProductVariablesType): Promise<boolean> => {
    try {
      loading.value = true

      const { errors } = await client.mutate({
        mutation: updateProductGql,
        variables
      })

      if (errors) {
        console.error('Mutation Error:', errors)

        return false
      }

      return true
    } catch (error) {
      console.error('Catch Mutation Error:', error)

      return false
    } finally {
      loading.value = false
    }
  }

  return {
    loading,
    products,
    fetchProducts,
    createProduct,
    updateProduct
  }
})
