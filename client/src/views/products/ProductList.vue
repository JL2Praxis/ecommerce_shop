<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { formatDateTime } from '@/utils/datetime'
import { ProductType as Product, ButtonType } from '@/_types/types'
import { ProductStatus, ProductType } from '@/enums/product'
import { formatPrice } from '@/utils/format'
import useProducts from '@/composables/useProducts'
import DataTable from '@/components/table/DataTable.vue'
import ActionButton from '@/components/button/ActionButton.vue'
import SearchBar from '@/components/search_bar/SearchBar.vue'

const router = useRouter()

const {
  products,
  handleFetchProducts
} = useProducts()

const filteredProducts = ref<Product[]>(products.value as Product[])

const headers: string[] = ['Name', 'Status', 'Price', 'Type', 'Modified', 'Published']
const buttons: ButtonType[] = [
  { title: 'Filter', type: 'normal', icon: 'pr-filter', handler: () => {} },
  { title: 'Select', type: 'normal', icon: 'pr-check-square', handler: () => {} },
  { title: 'New Product', type: 'success', icon: 'pr-plus', handler: () => router.push({ name: 'ProductNew' }) }
]

// TODO: Add pagination
const handleSearch = (val: string): void => {
  const searchVal = val.toLowerCase()
  if (!val) {
    filteredProducts.value = products.value as Product[]
  } else {
    filteredProducts.value = products.value.filter(product => {
      const nameWords = product.name.toLowerCase().split(' ')

      return nameWords.some(word => word.includes(searchVal))
    }) as Product[]
  }
}

const handleRowClick = (id: string): void => {
  router.push({ name: 'ProductEdit', params: { id } })
}

const getImageUrl = (name?: string): string => {
  return new URL(`/src/assets/images/${name || 'issue_04'}.png`, import.meta.url)?.href
}

onMounted(async () => {
  await handleFetchProducts()

  filteredProducts.value = products.value as Product[]
})
</script>
<template>
  <div class="products">
    <h6 class="header">Products</h6>
    <div class="products-subheader">
      <p class="products-subheader-info">
        {{ `${filteredProducts.length || 0} Products` }}
      </p>
      <div class="products-subheader-actions">
        <SearchBar
          placeholder="Search products..."
          @update="(val) => handleSearch(val)"
        />
        <div class="products-subheader-actions-buttons">
          <ActionButton
            v-for="button in buttons"
            :key="button.title"
            :title="button.title"
            :type="button.type"
            :icon="button.icon"
            @click="button.handler"
          />
        </div>
      </div>
    </div>
    <DataTable
      class="products-table"
      :headers="headers"
    >
      <tr
        v-for="product in filteredProducts"
        :key="product.id"
        @click="() => handleRowClick(product.id)"
      >
        <td>
          <!-- TODO: Add empty image grey rectangle -->
          <!-- TODO: Add image to product -->
          <img
            :src="getImageUrl()"
            alt="Product thumbnail"
          />
          <span>{{ product.name }}</span>
        </td>
        <td>{{ ProductStatus[product.status] }}</td>
        <td>{{ formatPrice(product.price) }}</td>
        <td>{{ ProductType[product.productType] }}</td>
        <td>{{ formatDateTime(product.updatedAt) }}</td>
        <!-- Change to publishedAt -->
        <td>{{ formatDateTime(product.createdAt) }}</td>
      </tr>
    </DataTable>
  </div>
</template>
<style lang="scss">
@import './productList.scss';
</style>
